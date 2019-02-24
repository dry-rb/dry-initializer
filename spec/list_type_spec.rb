require "dry-types"

describe "list type argument" do
  before do
    class Test::Foo
      extend Dry::Initializer
      param  :foo, [proc(&:to_s)]
      option :bar, [Dry::Types["strict.string"]]
      option :baz, []
    end
  end

  context "with single items" do
    subject { Test::Foo.new(1, bar: "2", baz: { qux: :QUX }) }

    it "coerces and wraps them to arrays" do
      expect(subject.foo).to eq %w[1]
      expect(subject.bar).to eq %w[2]
      expect(subject.baz).to eq [{ qux: :QUX }]
    end
  end

  context "with arrays" do
    subject { Test::Foo.new([1], bar: %w[2], baz: [{ qux: :QUX }]) }

    it "coerces elements" do
      expect(subject.foo).to eq %w[1]
      expect(subject.bar).to eq %w[2]
      expect(subject.baz).to eq [{ qux: :QUX }]
    end
  end
end
