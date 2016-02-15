describe "Dry type" do
  before do
    class Test::Foo
      extend Dry::Initializer

      argument :foo, type: Dry::Types::Coercible::String
    end
  end

  pending context "in case of mismatch" do
    subject { Test::Foo.new :foo }

    it "raises TypeError" do
      expect { subject }.to raise_error TypeError, /:foo/
    end
  end

  pending context "in case of match" do
    subject { Test::Foo.new "foo" }

    it "completes the initialization" do
      expect { subject }.not_to raise_error
    end
  end
end
