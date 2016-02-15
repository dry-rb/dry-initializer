describe "base example" do
  before do
    class Test::Foo
      extend Dry::Initializer

      argument  :foo
      parameter :bar # alias for `argument`

      option    :baz
      attribute :qux # alias for `option`
    end
  end

  it "instantiates arguments" do
    subject = Test::Foo.new(1, 2, baz: 3, qux: 4)

    expect(subject.foo).to eql 1
    expect(subject.bar).to eql 2
    expect(subject.baz).to eql 3
    expect(subject.qux).to eql 4
  end
end
