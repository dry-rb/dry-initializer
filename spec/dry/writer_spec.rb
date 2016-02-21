describe "writer" do
  subject do
    class Test::Foo
      extend Dry::Initializer

      param  :foo, writer: true
      option :bar, writer: true
      option :baz
    end

    Test::Foo.new 1, bar: 2, baz: 3
  end

  it "turned off by default" do
    expect(subject).not_to respond_to :baz=
  end

  it "defines attr_writer explicitly" do
    expect { subject.foo = 5 }.to change { subject.foo }.to 5
    expect { subject.bar = 7 }.to change { subject.bar }.to 7
  end
end
