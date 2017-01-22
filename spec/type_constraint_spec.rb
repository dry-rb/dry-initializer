require "dry-types"

describe "type constraint" do
  context "by dry-type" do
    before do
      class Test::Foo
        extend Dry::Initializer::Mixin
        param :foo, Dry::Types["strict.string"], optional: true
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

    context "if optional value not set" do
      subject { Test::Foo.new }

      it "applies type constraint to Dry::Initializer::UNDEFINED" do
        expect { subject }.to raise_error Dry::Types::ConstraintError
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
