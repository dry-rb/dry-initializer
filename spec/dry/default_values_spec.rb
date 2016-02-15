describe "default values" do
  before do
    class Test::Foo
      extend Dry::Initializer

      parameter :foo, default: :FOO
      parameter :bar, default: -> { :BAR }
      option    :baz, default: :BAZ
      option    :qux, default: -> { :QUX }
    end
  end

  it "instantiate arguments" do
    subject = Test::Foo.new(1, 2, baz: 3, qux: 4)

    expect(subject.foo).to eql 1
    expect(subject.bar).to eql 2
    expect(subject.baz).to eql 3
    expect(subject.qux).to eql 4
  end

  it "applies default values" do
    subject = Test::Foo.new

    expect(subject.foo).to eql :FOO
    expect(subject.bar).to eql :BAR
    expect(subject.baz).to eql :BAZ
    expect(subject.qux).to eql :QUX
  end

  it "applies default values partially" do
    subject = Test::Foo.new 1, baz: 3

    expect(subject.foo).to eql 1
    expect(subject.bar).to eql :BAR
    expect(subject.baz).to eql 3
    expect(subject.qux).to eql :QUX
  end
end
