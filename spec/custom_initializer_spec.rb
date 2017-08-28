describe "custom initializer" do
  before do
    class Test::Foo
      extend Dry::Initializer

      param :bar

      def initialize(*args)
        super
        @bar *= 3
      end
    end

    class Test::Baz < Test::Foo
      param :qux

      def initialize(*args)
        super
        @qux += 1
      end
    end
  end

  it "reloads the initializer" do
    baz = Test::Baz.new(5, 5)

    expect(baz.bar).to eq 15 # 5 * 3
    expect(baz.qux).to eq 6  # 5 + 1
  end
end
