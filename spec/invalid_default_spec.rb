describe "invalid default value assignment" do
  subject do
    class Test::Foo
      extend Dry::Initializer

      param :foo, default: 1
    end
  end

  it "raises TypeError" do
    expect { subject }.to raise_error TypeError
  end
end
