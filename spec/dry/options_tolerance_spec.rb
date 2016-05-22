describe "options tolerance" do
  before do
    class Test::Foo
      extend Dry::Initializer::Mixin
    end

    class Test::Bar < Test::Foo
      tolerant_to_unknown_options
    end

    class Test::Baz < Test::Bar
      intolerant_to_unknown_options
    end
  end

  it "is strict by default" do
    expect { Test::Foo.new foo: :bar }.to raise_error(ArgumentError)
  end

  it "allows unknown options when switched on" do
    expect { Test::Bar.new foo: :bar }.not_to raise_error
  end

  it "can be switched off" do
    expect { Test::Baz.new foo: :bar }.to raise_error(ArgumentError)
  end
end
