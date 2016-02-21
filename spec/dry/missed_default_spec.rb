describe "missed default values" do
  subject do
    class Test::Foo
      extend Dry::Initializer

      param :foo, default: :FOO
      param :bar
    end
  end

  it "raises SyntaxError" do
    expect { subject }.to raise_error SyntaxError, /bar/
  end
end
