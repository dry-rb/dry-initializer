require "dry-types"

describe "value coercion via dry-types" do
  before do
    module Test::Types
      include Dry::Types.module
    end

    class Test::Foo
      extend Dry::Initializer

      param  :foo, type: Test::Types::Coercible::String
      option :bar, proc(&:to_i), default: proc { "16" }
    end
  end

  it "coerces assigned values" do
    subject = Test::Foo.new :foo, bar: "13"

    expect(subject.foo).to eql "foo"
    expect(subject.bar).to eql 13
  end

  it "coerces defaults as well" do
    subject = Test::Foo.new :foo

    expect(subject.bar).to eql 16
  end
end
