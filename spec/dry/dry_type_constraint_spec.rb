require "dry-types"

describe "Dry type constraint" do
  before do
    module Test::Types
      include Dry::Types.module
    end

    class Test::Foo
      extend Dry::Initializer::Mixin
      param :foo, type: Test::Types::Strict::String
    end
  end

  context "in case of mismatch" do
    subject { Test::Foo.new 1 }

    it "raises TypeError" do
      expect { subject }.to raise_error TypeError, /1/
    end
  end

  context "in case of match" do
    subject { Test::Foo.new "foo" }

    it "completes the initialization" do
      expect { subject }.not_to raise_error
    end
  end
end
