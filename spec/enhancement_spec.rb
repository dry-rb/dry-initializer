describe "gem enhancement" do
  before do
    Dry::Initializer::Attribute.dispatchers << ->(string: false, **op) do
      op[:type] = proc(&:to_s) if string
      op
    end

    class Test::Foo
      extend Dry::Initializer
      param :bar, string: true
    end
  end

  it "works" do
    foo = Test::Foo.new(:BAZ)
    expect(foo.bar).to eq "BAZ"
  end
end
