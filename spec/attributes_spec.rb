# frozen_string_literal: true

describe Dry::Initializer, "dry_initializer.attributes" do
  subject { instance.class.dry_initializer.attributes(instance) }

  context "when class has params" do
    before do
      class Test::Foo
        extend Dry::Initializer
        param :foo, proc(&:to_s)
        param :bar, default: proc { 1 }
        param :baz, optional: true
      end
    end

    let(:instance) { Test::Foo.new(:FOO) }

    it "collects coerced params with default values" do
      expect(subject).to eq({foo: "FOO", bar: 1})
    end

    context "with unknown params" do
      let(:instance) { Test::Foo.new(:FOO, :BAR, :BAZ, :FUTZ) }

      it "ignores extra params" do
        expect(subject).to eq({foo: "FOO", bar: :BAR, baz: :BAZ})
      end
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

    let(:instance) { Test::Foo.new(foo: :FOO, qux: :QUX) }

    it "collects coerced and renamed options with default values" do
      expect(subject).to eq({foo: :FOO, bar: 1, quxx: "QUX"})
    end

    context "with extra unknown options" do
      let(:instance) { Test::Foo.new(foo: :FOO, qux: :QUX, futz: :FUTZ) }

      it "ignores extra options" do
        expect(subject).to eq({foo: :FOO, bar: 1, quxx: "QUX"})
      end
    end
  end
end
