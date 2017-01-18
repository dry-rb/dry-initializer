describe "@__options__" do
  context "when class has no options" do
    before do
      class Test::Foo
        extend Dry::Initializer::Mixin
        param :foo
      end
    end

    it "is set to empty hash" do
      subject = Test::Foo.new(1)

      expect(subject.instance_variable_get(:@__options__)).to eq({})
    end
  end

  context "when class has options" do
    before do
      class Test::Foo
        extend Dry::Initializer::Mixin
        param  :foo
        option :bar
        option :baz
      end
    end

    it "is set to empty hash if no options assigned" do
      subject = Test::Foo.new(1)

      expect(subject.instance_variable_get(:@__options__)).to eq({})
    end

    it "is set to hash of assigned options" do
      subject = Test::Foo.new(1, baz: :QUX)

      expect(subject.instance_variable_get(:@__options__)).to eq({ baz: :QUX })
    end
  end
end
