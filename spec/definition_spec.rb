describe "definition" do
  shared_examples :initializer do |in_context|
    subject { Test::Foo.new(1, bar: 2) }

    it "sets variables when defined by #{in_context}" do
      expect(subject.instance_variable_get(:@foo)).to eql 1
      expect(subject.instance_variable_get(:@bar)).to eql 2
    end
  end

  it_behaves_like :initializer, "extending Dry::Initializer" do
    before do
      class Test::Foo
        extend Dry::Initializer
        param  :foo
        option :bar
      end
    end
  end

  it_behaves_like :initializer, "extending Dry::Initializer::Mixin" do
    before do
      class Test::Foo
        extend Dry::Initializer::Mixin
        param  :foo
        option :bar
      end
    end
  end

  it_behaves_like :initializer, "extending Dry::Initializer[undefined: false]" do
    before do
      class Test::Foo
        extend Dry::Initializer[undefined: false]
        param  :foo
        option :bar
      end
    end
  end

  it_behaves_like :initializer, "including Dry::Initializer with block" do
    before do
      class Test::Foo
        include Dry::Initializer.define {
          param  :foo
          option :bar
        }
      end
    end
  end

  it_behaves_like :initializer, "including Dry::Initializer with lambda" do
    before do
      class Test::Foo
        include Dry::Initializer.define -> do
          param  :foo
          option :bar
        end
      end
    end
  end

  it_behaves_like :initializer, "including Dry::Initializer[undefined: false]" do
    before do
      class Test::Foo
        include Dry::Initializer[undefined: false].define {
          param  :foo
          option :bar
        }
      end
    end
  end

  it_behaves_like :initializer, "including Dry::Initializer::Mixin" do
    before do
      class Test::Foo
        include Dry::Initializer::Mixin.define {
          param  :foo
          option :bar
        }
      end
    end
  end
end
