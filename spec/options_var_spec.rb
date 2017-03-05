describe "@__options__" do
  context "when class has no options" do
    before do
      class Test::Foo
        extend Dry::Initializer::Mixin
        param :foo
      end
    end

    it "is set to empty hash" do
      subject = Test::Foo.new(1)

      expect(subject.instance_variable_get(:@__options__)).to eq({})
    end
  end

  context "when class has options" do
    before do
      class Test::Foo
        extend Dry::Initializer::Mixin
        option :foo
        option :bar, default: proc { 1 }
        option :baz, optional: true
        option :qux, proc(&:to_s), as: :quxx
      end
    end

    it "collects coerced and renamed options with default values" do
      subject = Test::Foo.new(foo: :FOO, qux: :QUX)

      expect(subject.instance_variable_get(:@__options__))
        .to eq({ foo: :FOO, bar: 1, quxx: "QUX" })
    end
  end
end
