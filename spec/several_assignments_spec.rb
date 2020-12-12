describe "attribute with several assignments" do
  before do
    class Test::Foo
      extend Dry::Initializer

      option :bar, proc(&:to_s),    optional: true
      option :"some foo", as: :bar, optional: true
    end
  end

  context "when not defined" do
    subject { Test::Foo.new }

    it "is left undefined" do
      expect(subject.bar).to be_nil
      expect(subject.instance_variable_get :@bar)
        .to eq Dry::Initializer::UNDEFINED
    end
  end

  context "when set directly" do
    subject { Test::Foo.new bar: :BAZ }

    it "sets the attribute" do
      expect(subject.bar).to eq "BAZ"
    end
  end

  context "when renamed" do
    subject { Test::Foo.new "some foo": :BAZ }

    it "renames the attribute" do
      expect(subject.bar).to eq :BAZ
      expect(subject).not_to respond_to :foo
    end

    it "renames the variable" do
      expect(subject.instance_variable_get(:@bar)).to eq :BAZ
    end
  end
end
