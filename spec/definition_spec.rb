describe "definition" do
  shared_examples :initializer do |in_context|
    subject { Test::Foo.new(1, bar: 2) }

    it "sets variables when defined via `#{in_context}`" do
      expect(subject.instance_variable_get(:@foo)).to eql 1
      expect(subject.instance_variable_get(:@bar)).to eql 2
    end
  end

  it_behaves_like :initializer, "extend Dry::Initializer" do
    before do
      class Test::Foo
        extend Dry::Initializer
        param  :foo
        option :bar
      end
    end

    it "preservers definition params" do
      params = Test::Foo.dry_initializer.params.map do |definition|
        [definition.source, definition.options]
      end

      expect(params).to eq [
        [:foo, { as: :foo, reader: :public, optional: false }]
      ]
    end

    it "preservers definition options" do
      options = Test::Foo.dry_initializer.options.map do |definition|
        [definition.source, definition.options]
      end

      expect(options).to eq [
        [:bar, { as: :bar, reader: :public, optional: false }]
      ]
    end
  end

  it_behaves_like :initializer, "extend Dry::Initializer" do
    before do
      class Test::Foo
        extend Dry::Initializer
        param  :foo
        option :bar
      end
    end
  end

  it_behaves_like :initializer, "extend Dry::Initializer[undefined: false]" do
    before do
      class Test::Foo
        extend Dry::Initializer[undefined: false]
        param  :foo
        option :bar
      end
    end
  end

  it_behaves_like :initializer, "include Dry::Initializer with block" do
    before do
      class Test::Foo
        include(
          Dry::Initializer.define do
            param  :foo
            option :bar
          end
        )
      end
    end
  end

  it_behaves_like :initializer, "include Dry::Initializer with lambda" do
    before do
      class Test::Foo
        include Dry::Initializer.define -> do
          param  :foo
          option :bar
        end
      end
    end
  end

  it_behaves_like :initializer, "include Dry::Initializer[undefined: false]" do
    before do
      class Test::Foo
        include(
          Dry::Initializer[undefined: false].define do
            param  :foo
            option :bar
          end
        )
      end
    end
  end

  # @deprecated
  it_behaves_like :initializer, "include Dry::Initializer::Mixin" do
    before do
      class Test::Foo
        include(
          Dry::Initializer::Mixin.define do
            param  :foo
            option :bar
          end
        )
      end
    end
  end
end
