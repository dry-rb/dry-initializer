# frozen_string_literal: true

# The per-class mixin that `extend Dry::Initializer` installs is an
# anonymous module. By default it would print as `#<Module:0x000...>` in
# ancestors output, backtraces, and `inspect` — noisy and uninformative.
# These tests pin down the user-visible effect: that mixin renders as
# `Dry::Initializer::Mixin::Local[<class>]` instead.

RSpec.describe "Dry::Initializer mixin inspection" do
  before do
    class Test::Foo
      extend Dry::Initializer
      param :foo
    end
  end

  let(:mixin) { Test::Foo.dry_initializer.mixin }

  it "shows up in the class's ancestors with a class-named label" do
    expect(Test::Foo.ancestors.map(&:to_s))
      .to include("Dry::Initializer::Mixin::Local[Test::Foo]")
  end

  it "renders the same string from inspect, to_s, and string interpolation" do
    expected = "Dry::Initializer::Mixin::Local[Test::Foo]"

    expect(mixin.inspect).to eq(expected)
    expect(mixin.to_s).to eq(expected)
    expect("includes #{mixin}").to eq("includes #{expected}")
  end

  it "uses each class's own name when more than one class extends Dry::Initializer" do
    class Test::Bar
      extend Dry::Initializer
      param :bar
    end

    foo_mixin = Test::Foo.dry_initializer.mixin
    bar_mixin = Test::Bar.dry_initializer.mixin

    expect(foo_mixin.to_s).to eq("Dry::Initializer::Mixin::Local[Test::Foo]")
    expect(bar_mixin.to_s).to eq("Dry::Initializer::Mixin::Local[Test::Bar]")
  end

  it "falls back to the class's inspect for anonymous classes" do
    klass = Class.new { extend Dry::Initializer; param :foo }

    expect(klass.dry_initializer.mixin.to_s)
      .to match(/\ADry::Initializer::Mixin::Local\[#<Class:0x\h+>\]\z/)
  end
end
