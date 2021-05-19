require "dry-types"

describe "type constraint" do
  context "by a proc with 1 argument" do
    before do
      class Test::Foo
        extend Dry::Initializer
        param :__foo__, proc(&:to_s), optional: true
      end
    end

    subject { Test::Foo.new :foo }

    it "coerces a value" do
      expect(subject.__foo__).to eq "foo"
    end
  end

  context "by a proc with 2 arguments" do
    before do
      class Test::Foo
        extend Dry::Initializer
        param :foo, proc { |val, obj| "#{obj.hash}:#{val}" }, optional: true
      end
    end

    subject { Test::Foo.new :foo }

    it "coerces a value with self as a second argument" do
      expect(subject.foo).to eq "#{subject.hash}:foo"
    end
  end

  context "by dry-type" do
    before do
      constraint = self.constraint

      Test::Foo = Class.new do
        extend Dry::Initializer
        param :foo, constraint, optional: true
      end
    end

    context "with a strict string" do
      let(:constraint) { Dry::Types["strict.string"] }

      context "in case of mismatch" do
        subject { Test::Foo.new 1 }

        it "raises ArgumentError" do
          expect { subject }.to raise_error Dry::Initializer::CoercionError, /1.*for field :foo/
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

        it "not applicable to Dry::Initializer::UNDEFINED" do
          expect(subject.instance_variable_get(:@foo))
            .to eq Dry::Initializer::UNDEFINED
        end
      end
    end

    context "with a integer member array" do
      let(:constraint) { Dry::Types["array"].of(Dry::Types["coercible.integer"]) }

      context "with arity other than 1" do
        subject { Test::Foo.new ["1"] }

        it "completes the initialization" do
          expect(subject.foo).to eql([1])
        end
      end

      context "when value is not valid" do
        subject { Test::Foo.new "foo" }

        it "raises constraint error" do
          expect { subject }.to raise_error(Dry::Initializer::CoercionError, /foo/)
        end
      end

      context "when member value is not valid" do
        subject { Test::Foo.new ["foo"] }

        it "raises constraint error" do
          expect { subject }.to raise_error(Dry::Types::CoercionError, /foo/)
        end
      end
    end
  end

  context "by invalid constraint" do
    it "raises ArgumentError" do
      expect do
        class Test::Foo
          extend Dry::Initializer
          param :foo, type: String
        end
      end.to raise_error(ArgumentError)
    end
  end
end
