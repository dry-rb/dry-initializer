describe "renaming options" do
  before do
    class Test::Foo
      extend Dry::Initializer::Mixin

      option :foo, as: :bar
    end
  end

  subject { Test::Foo.new foo: :BAZ }

  it "renames the attribute" do
    expect(subject.bar).to eq :BAZ
    expect(subject).not_to respond_to :foo
  end

  it "renames the variable" do
    expect(subject.instance_variable_get(:@bar)).to eq :BAZ
    expect(subject.instance_variable_get(:@foo)).to be_nil
  end
end
