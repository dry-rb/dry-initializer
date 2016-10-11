describe "shared definition" do
  subject do
    class Test::Foo
      extend Dry::Initializer::Mixin

      using default: proc { nil } do
        param  :foo
        option :bar
        option :baz, default: proc { 0 }
      end
    end
  end

  it "is applied to params and options" do
    expect(subject.new.foo).to be_nil
    expect(subject.new.bar).to be_nil
  end

  it "can be reloaded" do
    expect(subject.new.baz).to eq 0
  end
end
