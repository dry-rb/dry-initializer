describe "attributes writer" do
  subject do
    class Test::Foo
      extend Dry::Initializer

      param  :foo
      param  :bar
      option :baz
      option :qux

      attributes :attributes, :bar, :baz, :qux, writer: true
    end

    Test::Foo.new(1, 2, baz: 3, qux: 4)
  end

  it "defines hash writer" do
    subject.attributes = { bar: 7, baz: 8, qux: 9 }

    expect(subject.bar).to eql 7
    expect(subject.baz).to eql 8
    expect(subject.qux).to eql 9
  end

  it "supports partial assignment" do
    subject.attributes = { bar: 7 }

    expect(subject.bar).to eql 7
    expect(subject.baz).to eql 3
    expect(subject.qux).to eql 4
  end

  it "fails when unknown key given" do
    expect { subject.attributes = { foo: 1 } }.to raise_error KeyError, /foo/
  end
end
