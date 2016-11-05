describe "default nil" do
  before do
    class Test::Foo
      extend Dry::Initializer::Mixin

      param :foo, default: proc { nil }
      param :bar, default: proc { nil }
    end
  end

  it "is assigned" do
    subject = Test::Foo.new(1)

    expect(subject.foo).to eql 1
    expect(subject.bar).to be_nil
  end
end
