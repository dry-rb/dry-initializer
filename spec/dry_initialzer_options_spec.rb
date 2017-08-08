describe "#dry_initializer_options" do
  subject do
    class Test::Foo
      extend Dry::Initializer::Mixin

      param :foo
      param :bar, ->(v) { "#{v}100" }

      option :baz, default: -> { true }
      option :caz, reader: :private
      option :daz, ->(v) { "#{v}200" }, default: -> { "300" }
    end

    Test::Foo.new("1", "2", caz: 500)
  end

  it "returns correct options" do
    expect(subject.dry_initializer_options).to eq(
      foo: "1", bar: "2100", baz: true, daz: "300200"
    )
  end
end
