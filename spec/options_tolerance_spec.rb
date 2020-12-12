describe "options tolerance" do
  before do
    class Test::Foo
      extend Dry::Initializer
    end
  end

  it "allows options before any definition" do
    expect { Test::Foo.new bar: :baz }.not_to raise_error
  end
end
