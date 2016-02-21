describe "invalid type declaration" do
  subject do
    class Test::Foo
      extend Dry::Initializer

      param :foo, type: 1
    end
  end

  it "raises TypeError" do
    expect { subject }.to raise_error TypeError, /1/
  end
end
