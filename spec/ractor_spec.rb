# frozen_string_literal: true

# Ractor compatibility tests for dry-initializer.
#
# Purpose: pin down which usage patterns work across Ractor boundaries
# today, and document the exact exception each remaining failure raises
# — so the supported surface is explicit and regressions are visible.
#
# The supported pattern is: define a class in the main Ractor, call
# `finalize` on it, then instantiate or subclass it from any Ractor.
# Non-finalized classes are not expected to cross Ractor boundaries —
# that's a precondition, the same shape as other Ractor preconditions
# (you make_shareable what you want to send), not a bug to track here.

RSpec.describe Dry::Initializer, "Ractor compatibility" do
  before do
    skip "Ractor not available" unless defined?(Ractor)
    skip "Ractor tests gated to Ruby 4.0+" if RUBY_VERSION < "4"
  end

  # Several tests deliberately let a Ractor crash. Suppress the
  # `Thread#report_on_exception` chatter so the spec output stays clean.
  around do |example|
    previous = Thread.report_on_exception
    Thread.report_on_exception = false
    example.run
  ensure
    Thread.report_on_exception = previous
  end

  # `Ractor#value` (and `#take` on older Rubies) wraps a remote raise in
  # `Ractor::RemoteError`, with the original exception accessible via
  # `#cause`. Walk the chain so matchers don't depend on the wrapper.
  def cause_chain(error)
    chain = []
    while error
      chain << error
      error = error.cause
    end
    chain
  end

  def caused_by?(error, klass, message_includes: nil)
    cause_chain(error).any? do |e|
      e.is_a?(klass) &&
        (message_includes.nil? || e.message.to_s.include?(message_includes))
    end
  end

  describe "calling .new on a main-Ractor class from a non-main Ractor" do
    context "without finalize, with a default/type/rename" do
      before do
        class Test::Foo
          extend Dry::Initializer
          param  :foo, default: -> { "default" }
          option :bar, ->(v) { v.to_s.upcase }, optional: true
        end
      end

      it "raises the bmethod un-shareable-Proc error" do
        ractor = Ractor.new { Test::Foo.new }

        expect { ractor.value }.to raise_error do |error|
          expect(
            caused_by?(error, RuntimeError, message_includes: "un-shareable Proc")
          ).to(be(true), "expected un-shareable-Proc RuntimeError, got #{error.class}: #{error.message}")
        end
      end
    end

    context "without finalize, with only plain params/options" do
      before do
        class Test::Foo
          extend Dry::Initializer
          param :foo
        end
      end

      # The generated `__dry_initializer_initialize__` for plain
      # declarations doesn't reference `__dry_initializer_config__`, so
      # the bmethod is never invoked. This is incidental: relying on it
      # means losing defaults, coercion, and renames. Documented here so
      # a regression in the code generator is visible.
      it "incidentally succeeds" do
        result = Ractor.new { Test::Foo.new("hi").foo }.value
        expect(result).to eq("hi")
      end
    end

    context "after finalize" do
      before do
        class Test::Foo
          extend Dry::Initializer
          param  :foo
          option :bar, default: -> { "default" }
          option :baz, ->(v) { v.to_s.upcase }, optional: true
          finalize
        end
      end

      it "instantiates and reads back the param" do
        result = Ractor.new { Test::Foo.new("hello").foo }.value
        expect(result).to eq("hello")
      end

      it "applies a default-valued option" do
        result = Ractor.new { Test::Foo.new("hello").bar }.value
        expect(result).to eq("default")
      end

      it "applies type coercion to options" do
        result = Ractor.new { Test::Foo.new("x", baz: "yo").baz }.value
        expect(result).to eq("YO")
      end

      it "exposes attributes via dry_initializer.public_attributes" do
        result = Ractor.new do
          instance = Test::Foo.new("a", baz: "b")
          Test::Foo.dry_initializer.public_attributes(instance)
        end.value

        expect(result).to eq(foo: "a", bar: "default", baz: "B")
      end
    end

    context "after finalize, with a default that references another param" do
      before do
        class Test::Greeter
          extend Dry::Initializer
          param  :name
          option :upcased_name, default: -> { name.upcase }
          finalize
        end
      end

      # The default is `instance_exec`'d so `self` inside the Proc is the
      # instance — `name` resolves to the reader method, not a captured
      # local. Inline class-body defaults are made shareable by finalize's
      # `Ractor.make_shareable`, so this composes cleanly with cross-Ractor
      # instantiation.
      it "resolves the reference at .new time from a non-main Ractor" do
        result = Ractor.new { Test::Greeter.new("alice").upcased_name }.value
        expect(result).to eq("ALICE")
      end
    end
  end

  describe "Dry::Initializer#finalize" do
    let(:klass) do
      Class.new do
        extend Dry::Initializer
        param  :foo
        option :bar, default: -> { 1 }
      end
    end

    it "returns the class itself" do
      expect(klass.finalize).to be(klass)
    end

    it "is idempotent" do
      klass.finalize
      expect { klass.finalize }.not_to raise_error
    end

    it "rejects further param definitions with FrozenError" do
      klass.finalize
      expect { klass.param :added }.to raise_error(FrozenError)
    end

    it "rejects further option definitions with FrozenError" do
      klass.finalize
      expect { klass.option :added_opt }.to raise_error(FrozenError)
    end

    it "leaves main-Ractor instantiation working" do
      klass.finalize
      instance = klass.new("hi")
      expect(instance.foo).to eq("hi")
      expect(instance.bar).to eq(1)
    end

    it "makes the config Ractor-shareable" do
      klass.finalize
      expect(Ractor.shareable?(klass.dry_initializer)).to be(true)
    end
  end

  describe "subclassing" do
    before do
      class Test::Parent
        extend Dry::Initializer
        param :foo
        finalize
      end
    end

    context "in the main Ractor, after the parent is finalized" do
      # The new subclass starts with its own non-finalized Config and
      # can be finalized independently.
      it "succeeds and yields an independent, non-finalized child" do
        child = Class.new(Test::Parent) { param :bar }

        expect(child.new("a", "b").foo).to eq("a")
        expect(child.dry_initializer).not_to be(Test::Parent.dry_initializer)
        expect(Test::Parent.subclasses).to include(child)
      end
    end

    context "in a non-main Ractor, with a finalized main-Ractor parent" do
      it "succeeds and produces a usable subclass" do
        result = Ractor.new do
          child = Class.new(Test::Parent)
          child.new("hello").foo
        end.value

        expect(result).to eq("hello")
      end
    end
  end

  describe "defining a class inside a non-main Ractor" do
    it "succeeds and produces a usable class" do
      result = Ractor.new do
        klass = Class.new do
          extend Dry::Initializer
          param  :name, ->(v) { v.to_s.upcase }
          option :count, default: -> { 1 }
        end
        instance = klass.new("alice", count: 5)
        [instance.name, instance.count]
      end.value

      expect(result).to eq(["ALICE", 5])
    end
  end
end
