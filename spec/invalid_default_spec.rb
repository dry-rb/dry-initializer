# frozen_string_literal: true

RSpec.describe "invalid default value assignment" do
  shared_examples "it has a TypeError" do
    it "raises TypeError" do
      expect { subject }.to raise_error TypeError
    end
  end

  subject do
    class Test::Foo
      extend Dry::Initializer

      param :foo, default: 1
    end
  end

  it_behaves_like "it has a TypeError"

  context "when default is false" do
    subject do
      class Test::Foo
        extend Dry::Initializer

        param :foo, default: false
      end
    end

    it_behaves_like "it has a TypeError"
  end

  context "when default is a lambda returning false" do
    subject do
      class Test::Foo
        extend Dry::Initializer

        param :foo, default: -> { false }
      end
    end

    it "does not raise TypeError" do
      expect { subject }.not_to raise_error
    end
  end
end
