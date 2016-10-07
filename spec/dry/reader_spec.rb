describe "reader" do
  context "with reader: false" do
    subject do
      class Test::Foo
        extend Dry::Initializer::Mixin

        param  :foo, reader: false
        option :bar, reader: false
      end

      Test::Foo.new 1, bar: 2
    end

    it "skips attr_reader" do
      expect(subject).not_to respond_to :foo
      expect(subject).not_to respond_to :bar
    end

    it "keeps assigning variables" do
      expect(subject.instance_variable_get(:@foo)).to eql 1
      expect(subject.instance_variable_get(:@bar)).to eql 2
    end
  end
end
