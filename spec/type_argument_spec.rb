# frozen_string_literal: true

require "dry-types"

RSpec.describe "type argument" do
  before do
    class Test::Foo
      extend Dry::Initializer
      param  :foo, Dry::Types["strict.string"]
      option :bar, Dry::Types["strict.string"]
    end
  end

  context "in case of param mismatch" do
    subject { Test::Foo.new 1, bar: "2" }

    it "raises TypeError" do
      expect { subject }.to raise_error Dry::Initializer::CoercionError, /1.* for field :foo/
    end
  end

  context "in case of option mismatch" do
    subject { Test::Foo.new "1", bar: 2 }

    it "raises TypeError" do
      expect { subject }.to raise_error Dry::Initializer::CoercionError, /2.*for field :bar/
    end
  end

  context "in case of match" do
    subject { Test::Foo.new "1", bar: "2" }

    it "completes the initialization" do
      expect { subject }.not_to raise_error
    end
  end
end
