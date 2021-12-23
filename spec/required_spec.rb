# frozen_string_literal: true

describe "required param" do
  before do
    class Test::Foo
      extend Dry::Initializer

      param :foo
      param :bar, optional: true
    end
  end

  it "raise ArgumentError" do
    expect { Test::Foo.new }.to raise_exception(ArgumentError)
  end
end

describe "required option" do
  before do
    class Test::Foo
      extend Dry::Initializer

      option :foo
      option :bar, optional: true
    end
  end

  it "raise ArgumentError" do
    expect { Test::Foo.new }.to raise_exception(ArgumentError)
  end
end
