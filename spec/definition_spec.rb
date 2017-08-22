describe "definition" do
  shared_examples :initializer do |in_context|
    subject { Test::Foo.new(1, bar: 2) }

    it "sets variables when defined via `#{in_context}`" do
      expect(subject.instance_variable_get(:@foo)).to eql 1
      expect(subject.instance_variable_get(:@bar)).to eql 2
    end
  end

  it_behaves_like :initializer, "extend Dry::Initializer" do
    before do
      class Test::Foo
        extend Dry::Initializer
        param  :foo
        option :bar
      end
    end
  end

  it_behaves_like :initializer, "extend Dry::Initializer" do
    before do
      class Test::Foo
        extend Dry::Initializer
        param  :foo
        option :bar
      end
    end
  end

  it_behaves_like :initializer, "extend Dry::Initializer[undefined: false]" do
    before do
      class Test::Foo
        extend Dry::Initializer[undefined: false]
        param  :foo
        option :bar
      end
    end
  end
end