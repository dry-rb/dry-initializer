describe "repetitive definitions" do
  subject { Test::Foo.new }

  context "of params" do
    before do
      class Test::Foo
        extend Dry::Initializer

        param :foo, default: proc { 0 }
        param :bar, default: proc { 1 }
        param :foo, default: proc { 2 }
      end
    end

    it "reloads the attribute" do
      expect(subject.foo).to eq 2
    end
  end

  context "of options" do
    before do
      class Test::Foo
        extend Dry::Initializer

        option :foo, default: proc { 0 }
        option :bar, default: proc { 1 }
        option :foo, default: proc { 2 }
      end
    end

    it "reloads the attribute" do
      expect(subject.foo).to eq 2
    end
  end

  context "of param and option" do
    before do
      class Test::Foo
        extend Dry::Initializer

        param  :foo, default: proc { 0 }
        option :bar, default: proc { 1 }
        option :foo, default: proc { 2 }
      end
    end

    it "reloads the attribute" do
      expect(subject.foo).to eq 2
    end
  end

  context "of optional param and option" do
    before do
      class Test::Foo
        extend Dry::Initializer

        param  :baz, optional: true, as: :foo
        option :bar, optional: true
        option :foo, optional: true
      end
    end

    it "allows various assignments" do
      expect(Test::Foo.new(1).foo).to eq 1
      expect(Test::Foo.new(foo: 2).foo).to eq 2
      expect(Test::Foo.new(1, foo: 2).foo).to eq 2
    end
  end
end
