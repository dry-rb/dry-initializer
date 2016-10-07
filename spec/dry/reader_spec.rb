describe "reader" do
  shared_examples "it has no public attr_reader" do
    it "does not define a public attr_reader" do
      expect(subject).not_to respond_to :foo
      expect(subject).not_to respond_to :bar
    end
  end

  context "with reader: false" do
    subject do
      class Test::Foo
        extend Dry::Initializer::Mixin

        param  :foo, reader: false
        option :bar, reader: false
      end

      Test::Foo.new 1, bar: 2
    end

    it_behaves_like "it has no public attr_reader"

    it "keeps assigning variables" do
      expect(subject.instance_variable_get(:@foo)).to eql 1
      expect(subject.instance_variable_get(:@bar)).to eql 2
    end
  end

  context "with reader: :private" do
    subject do
      class Test::Foo
        extend Dry::Initializer::Mixin

        param  :foo, reader: :private
        option :bar, reader: :private
      end

      Test::Foo.new 1, bar: 2
    end

    it_behaves_like "it has no public attr_reader"

    it "adds a private attr_reader" do
      expect(subject.send(:foo)).to eql 1
      expect(subject.send(:bar)).to eql 2
    end
  end
end
