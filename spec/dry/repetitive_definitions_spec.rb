describe "repetitive definitions" do
  context "of parameters" do
    subject do
      class Test::Foo
        extend Dry::Initializer

        parameter :foo
        parameter :bar
        parameter :foo
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

  context "of parameter and option" do
    subject do
      class Test::Foo
        extend Dry::Initializer

        parameter :foo
        option :bar
        option :foo
      end
    end

    it "raise SyntaxError" do
      expect { subject }.to raise_error SyntaxError, /foo/
    end
  end
end
