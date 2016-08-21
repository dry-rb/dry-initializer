describe "optional value" do
  context "when has no default value" do
    before do
      class Test::Foo
        extend Dry::Initializer::Mixin

        param :foo
        param :bar, optional: true
      end
    end

    it "is left UNDEFINED by default" do
      subject = Test::Foo.new(1)

      expect(subject.foo).to eq 1
      expect(subject.bar).to eq Dry::Initializer::UNDEFINED
    end

    it "can be set explicitly" do
      subject = Test::Foo.new(1, "qux")

      expect(subject.foo).to eq 1
      expect(subject.bar).to eq "qux"
    end
  end

  context "when has default value" do
    before do
      class Test::Foo
        extend Dry::Initializer::Mixin

        param :foo
        param :bar, optional: true, default: proc { "baz" }
      end
    end

    it "is takes default value" do
      subject = Test::Foo.new(1)

      expect(subject.foo).to eq 1
      expect(subject.bar).to eq "baz"
    end
  end
end
