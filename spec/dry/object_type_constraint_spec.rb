describe "object type constraint" do
  before do
    class Test::Foo
      extend Dry::Initializer::Mixin

      param :foo, type: /bar/
    end
  end

  context "in case of mismatch" do
    subject { Test::Foo.new "baz" }

    it "raises TypeError" do
      expect { subject }.to raise_error TypeError
    end
  end

  context "in case of match" do
    subject { Test::Foo.new "barbar" }

    it "completes the initialization" do
      expect { subject }.not_to raise_error
    end
  end
end
