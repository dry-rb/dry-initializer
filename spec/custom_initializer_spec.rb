describe "custom initializer" do
  before do
    class Test::Foo
      extend Dry::Initializer::Mixin

      param :bar

      def initialize(*args)
        super
        @bar *= 3
      end
    end

    class Test::Baz < Test::Foo
      param :qux
    end
  end

  it "reloads the initializer" do
    baz = Test::Baz.new(2, 8)

    expect(baz.bar).to eq 6 # 2 * 3
    expect(baz.qux).to eq 8
  end
end
