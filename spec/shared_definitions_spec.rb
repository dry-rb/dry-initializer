describe "shared definition" do
  subject do
    class Test::Foo
      extend Dry::Initializer::Mixin

      with_settings default: proc { nil } do
        param  :foo
        option :end
        option :baz, default: proc { 0 }
      end

      with_settings optional: true do
        option :qux
        option :quxx, optional: false
      end
    end
  end

  it "is applied to params and options" do
    instance = subject.new(quxx: 1)

    expect(instance.foo).to be_nil
    expect(instance.end).to be_nil
  end

  it "can be reloaded" do
    instance = subject.new(quxx: 1)

    expect(instance.baz).to eq 0
  end

  it "can reload :optional setting" do
    expect { subject.new }.to raise_error(KeyError, /quxx/)
  end
end
