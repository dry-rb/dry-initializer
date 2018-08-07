describe "coercion of nil" do
  before do
    class Test::Foo
      extend Dry::Initializer
      param :bar, proc(&:to_i)
    end

    class Test::Baz
      include Dry::Initializer.define -> do
        param :qux, proc(&:to_i)
      end
    end
  end

  let(:foo) { Test::Foo.new(nil) }
  let(:baz) { Test::Baz.new(nil) }

  it "works with extend syntax" do
    expect(foo.bar).to eq 0
  end

  it "works with include syntax" do
    expect(baz.qux).to eq 0
  end
end
