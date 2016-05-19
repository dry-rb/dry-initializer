describe "plugin registry" do
  before do
    # Define a plugin
    module Test::Stringifier
      class Plugin < Dry::Initializer::Plugins::Base
        def call
          "@#{name} = @#{name}.to_s"
        end
      end

      def self.extended(klass)
        klass.register_initializer_plugin(Plugin)
      end
    end

    # Define superclass
    class Test::Foo
      extend Dry::Initializer::Mixin

      param :foo
    end

    # Apply the plugin to the subclass
    class Test::Bar < Test::Foo
      extend Test::Stringifier

      param :bar
    end
  end

  let(:instance_of_superclass) { Test::Foo.new :FOO }
  let(:instance_of_subclass)   { Test::Bar.new :FOO, :BAR }

  it "does not pollute superclass" do
    expect(instance_of_superclass.foo).to eql :FOO
  end

  it "preserves declarations made in superclass" do
    expect(instance_of_subclass.foo).to eql :FOO
  end

  it "applies plugin to new declarations" do
    expect(instance_of_subclass.bar).to eql "BAR"
  end
end
