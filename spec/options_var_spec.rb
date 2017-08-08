describe "@__dry_initializer_options__" do
  context "when class has params" do
    before do
      class Test::Foo
        extend Dry::Initializer
        param :foo, proc(&:to_s)
        param :bar, default: proc { 1 }
        param :baz, optional: true
      end
    end

    it "collects coerced params with default values" do
      subject = Test::Foo.new(:FOO)

      expect(subject.instance_variable_get(:@__dry_initializer_options__))
        .to eq({ foo: "FOO", bar: 1 })
    end
  end

  context "when class has options" do
    before do
      class Test::Foo
        extend Dry::Initializer
        option :foo
        option :bar, default: proc { 1 }
        option :baz, optional: true
        option :qux, proc(&:to_s), as: :quxx
      end
    end

    it "collects coerced and renamed options with default values" do
      subject = Test::Foo.new(foo: :FOO, qux: :QUX)

      expect(subject.instance_variable_get(:@__dry_initializer_options__))
        .to eq({ foo: :FOO, bar: 1, quxx: "QUX" })
    end
  end
end
