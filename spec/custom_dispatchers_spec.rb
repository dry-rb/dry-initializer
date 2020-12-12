describe "custom dispatchers" do
  subject { Test::Foo.new "123" }

  before do
    dispatcher = ->(op) { op[:integer] ? op.merge(type: proc(&:to_i)) : op }
    Dry::Initializer::Dispatchers << dispatcher
  end

  context "with extend syntax" do
    before do
      class Test::Foo
        extend Dry::Initializer
        param :id, integer: true
      end
    end

    it "adds syntax sugar" do
      expect(subject.id).to eq 123
    end
  end

  context "with include syntax" do
    before do
      class Test::Foo
        include Dry::Initializer.define -> do
          param :id, integer: true
        end
      end
    end

    it "adds syntax sugar" do
      expect(subject.id).to eq 123
    end
  end
end
