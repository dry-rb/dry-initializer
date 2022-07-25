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

  context "when default is a lambda one attribute with splat operator" do
    subject do
      class Test::Foo
        extend Dry::Initializer

        param :foo, default: ->(a) { a.to_i }
      end
    end

    it_behaves_like "it has a TypeError"
  end

  context "when default is a proc with attributes" do
    subject do
      class Test::Foo
        extend Dry::Initializer

        param :foo, default: proc { |a| a.to_i }
      end
    end

    it_behaves_like "it has a TypeError"
  end

  context "when default is a callable with attributes" do
    subject do
      class Test::Callbale
        def self.call(a)
          a.to_i
        end
      end

      class Test::Foo
        extend Dry::Initializer

        param :foo, default: Test::Callbale
      end
    end

    it_behaves_like "it has a TypeError"
  end

  context "when default is a proc with multiple attributes" do
    subject do
      class Test::Foo
        extend Dry::Initializer

        param :foo, default: proc { |a, *b| a.to_i }
      end
    end

    it_behaves_like "it has a TypeError"
  end

  context "when default is a lambda one attribute with splat operator" do
    subject do
      class Test::Foo
        extend Dry::Initializer

        param :foo, default: ->(*a) { a.size }
      end
    end

    it "does not raise TypeError" do
      expect { subject }.not_to raise_error
    end
  end
end
