describe "attr_hash" do
  subject do
    class Test::Foo
      extend Dry::Initializer

      param  :foo
      param  :bar
      option :baz
      option :qux

      attr_hash :attributes, :bar, :baz, :qux
    end

    Test::Foo.new(1, 2, baz: 3, qux: 4)
  end

  it "defines a hash with given keys" do
    expect(subject.attributes).to eql(bar: 2, baz: 3, qux: 4)
  end

  it "does not define writer" do
    expect(subject).not_to respond_to :attributes=
  end
end
