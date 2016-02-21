describe "proc type" do
  before do
    class Test::Foo
      extend Dry::Initializer

      param :foo, type: proc { |val| fail(TypeError) unless String === val }
    end
  end

  context "in case of mismatch" do
    subject { Test::Foo.new :foo }

    it "raises TypeError" do
      expect { subject }.to raise_error TypeError
    end
  end

  context "in case of match" do
    subject { Test::Foo.new "foo" }

    it "completes the initialization" do
      expect { subject }.not_to raise_error
    end
  end
end
