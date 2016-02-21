describe "repetitive definitions" do
  context "of params" do
    subject do
      class Test::Foo
        extend Dry::Initializer

        param :foo
        param :bar
        param :foo
      end
    end

    it "raise SyntaxError" do
      expect { subject }.to raise_error SyntaxError, /foo/
    end
  end

  context "of options" do
    subject do
      class Test::Foo
        extend Dry::Initializer

        option :foo
        option :bar
        option :foo
      end
    end

    it "raise SyntaxError" do
      expect { subject }.to raise_error SyntaxError, /foo/
    end
  end

  context "of param and option" do
    subject do
      class Test::Foo
        extend Dry::Initializer

        param  :foo
        option :bar
        option :foo
      end
    end

    it "raise SyntaxError" do
      expect { subject }.to raise_error SyntaxError, /foo/
    end
  end
end
