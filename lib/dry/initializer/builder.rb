module Dry::Initializer
  # Rebuilds the initializer every time a new argument defined
  #
  # @api private
  #
  class Builder
    include Plugins

    def initialize
      @signature = Signature.new
      @plugins   = Set.new [VariableSetter, TypeConstraint, DefaultProc]
      @parts     = []
    end

    # Register new plugin to be applied as a chunk of code, or a proc
    # to be evaluated in the instance's scope
    #
    # @param [Dry::Initializer::Plugin]
    #
    def register(plugin)
      @plugins << plugin
    end

    # Defines new agrument and rebuilds the initializer
    #
    # @param [#to_sym] name
    # @param [Hash<Symbol, Object>] settings
    #
    # @return [self] itself
    #
    def define(name, settings)
      update_signature(name, settings)
      update_parts(name, settings)

      define_reader(name, settings)
      reload_initializer
      reload_callback

      self
    end

    # The module with two methods: `#initialize` and `##__after_initialize__`
    # to be mixed into the target class
    #
    # @return [Module]
    #
    def mixin
      @mixin ||= Module.new
    end

    private

    def update_signature(name, settings)
      @signature.add(name, settings)
    end

    def update_parts(name, settings)
      @parts += @plugins.map { |klass| klass.call(name, settings) }.compact
    end

    def define_reader(name, settings)
      mixin.send :attr_reader, name unless settings[:reader] == false
    end

    def reload_initializer
      strings = @parts.select { |part| String === part }

      mixin.class_eval <<-RUBY
        def initialize(#{@signature.call})
          #{strings.join("\n")}
          __after_initialize__
        end
      RUBY
    end

    def reload_callback
      blocks = @parts.select { |part| Proc === part }

      mixin.send :define_method, :__after_initialize__ do
        blocks.each { |block| instance_eval(&block) }
      end

      mixin.send :private, :__after_initialize__
    end
  end
end
