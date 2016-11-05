describe "reader" do
  shared_examples "it has no public attr_reader" do
    it "does not define a public attr_reader" do
      expect(subject).not_to respond_to :foo
      expect(subject).not_to respond_to :bar
    end
  end

  context "with reader: :public or no reader: option" do
    subject do
      class Test::Foo
        extend Dry::Initializer::Mixin

        param  :foo
        param  :foo2, reader: :public
        option :bar
        option :bar2, reader: :public
      end

      Test::Foo.new 1, 2, bar: 3, bar2: 4
    end

    it "defines a public attr_reader by default" do
      expect(subject).to respond_to(:foo, :foo2)
      expect(subject).to respond_to :bar
      expect(subject).to respond_to :bar2
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

  context "with reader: :protected" do
    subject do
      class Test::Foo
        extend Dry::Initializer::Mixin

        param  :foo, reader: :protected
        option :bar, reader: :protected
      end

      Test::Foo.new 1, bar: 2
    end

    it "adds a protected attr_reader" do
      protected_instance_methods = subject.class.protected_instance_methods
      expect(protected_instance_methods).to match_array([:foo, :bar])
    end
  end
end
