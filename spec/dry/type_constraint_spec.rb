require "dry-types"

describe "type constraint" do
  context "by dry-type" do
    before do
      module Test::Types
        include Dry::Types.module
      end

      class Test::Foo
        extend Dry::Initializer::Mixin
        param :foo, type: Test::Types::Strict::String
      end
    end

    context "in case of mismatch" do
      subject { Test::Foo.new 1 }

      it "raises TypeError" do
        expect { subject }.to raise_error TypeError, /1/
      end
    end

    context "in case of match" do
      subject { Test::Foo.new "foo" }

      it "completes the initialization" do
        expect { subject }.not_to raise_error
      end
    end
  end

  context "by invalid constraint" do
    it "raises TypeError" do
      expect {
        class Test::Foo
          extend Dry::Initializer::Mixin
          param :foo, type: String
        end
      }.to raise_error(TypeError)
    end
  end
end
