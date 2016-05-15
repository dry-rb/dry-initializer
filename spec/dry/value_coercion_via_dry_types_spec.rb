require "dry-types"

describe "value coercion via dry-types" do
  before do
    module Test::Types
      include Dry::Types.module
    end

    class Test::Foo
      extend Dry::Initializer::Mixin

      param :foo, type: Test::Types::Coercible::String
    end
  end

  subject { Test::Foo.new :foo }

  it "coerces values" do
    expect(subject.foo).to eql "foo"
  end
end
