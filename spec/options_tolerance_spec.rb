describe "options tolerance" do
  before do
    class Test::Foo
      extend Dry::Initializer::Mixin
      option :foo
    end

    class Test::Bar
      extend Dry::Initializer::Mixin
    end
  end

  it "allows unknown options when someone defined" do
    expect { Test::Foo.new foo: :bar, bar: :baz }.not_to raise_error
  end

  it "forbids options when no one defined" do
    expect { Test::Bar.new bar: :baz }.to raise_error(ArgumentError)
  end
end
