require "dry-types"

describe "type argument" do
  before do
    class Test::Foo
      extend Dry::Initializer
      param  :foo, Dry::Types["strict.string"]
      option :bar, Dry::Types["strict.string"]
    end
  end

  context "in case of param mismatch" do
    subject { Test::Foo.new 1, bar: "2" }

    it "raises TypeError" do
      expect { subject }.to raise_error TypeError, /1/
    end
  end

  context "in case of option mismatch" do
    subject { Test::Foo.new "1", bar: 2 }

    it "raises TypeError" do
      expect { subject }.to raise_error TypeError, /2/
    end
  end

  context "in case of match" do
    subject { Test::Foo.new "1", bar: "2" }

    it "completes the initialization" do
      expect { subject }.not_to raise_error
    end
  end
end
