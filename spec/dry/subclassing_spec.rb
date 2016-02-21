describe "subclassing" do
  subject do
    class Test::Foo
      extend Dry::Initializer

      param  :foo
      option :bar
    end

    class Test::Bar < Test::Foo
      param  :baz
      option :qux
    end

    Test::Bar.new 1, 2, bar: 3, qux: 4
  end

  it "preserves definitions made in the superclass" do
    expect(subject.foo).to eql 1
    expect(subject.baz).to eql 2
    expect(subject.bar).to eql 3
    expect(subject.qux).to eql 4
  end
end
