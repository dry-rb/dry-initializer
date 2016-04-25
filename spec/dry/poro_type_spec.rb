describe "PORO type" do
  before do
    class Test::Foo
      extend Dry::Initializer::Mixin

      param :foo, type: String
    end
  end

  context "in case of mismatch" do
    subject { Test::Foo.new :foo }

    it "raises TypeError" do
      expect { subject }.to raise_error TypeError, /:foo/
    end
  end

  context "in case of match" do
    subject { Test::Foo.new "foo" }

    it "completes the initialization" do
      expect { subject }.not_to raise_error
    end
  end

  context "in case of soft match" do
    subject { Test::Foo.new Class.new(String).new "foo" }

    it "completes the initialization" do
      expect { subject }.not_to raise_error
    end
  end
end
