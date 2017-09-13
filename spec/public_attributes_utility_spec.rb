describe Dry::Initializer, ".dry_initializer.public_attributes" do
  subject { instance.class.dry_initializer.public_attributes(instance) }

  context "when class has params" do
    before do
      class Test::Foo
        extend Dry::Initializer
        param  :foo, proc(&:to_s), desc: "a weird parameter"
        option :moo, optional: true
        option :bar, default: proc { 1 },     reader: false
        option :baz, optional: true,          reader: :protected
        option :qux, proc(&:to_s), as: :quxx, reader: :private
      end
    end

    let(:instance) { Test::Foo.new(:FOO, bar: :BAR, baz: :BAZ, qux: :QUX) }

    it "collects public options only" do
      expect(subject).to eq({ foo: "FOO", moo: nil })
    end
  end
end
