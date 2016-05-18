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
      plugins = @plugins + [plugin]
      copy { @plugins = plugins }
    end

    # Defines new agrument and reloads mixin definitions
    #
    # @param [Module] mixin
    # @param [#to_sym] name
    # @param [Hash<Symbol, Object>] settings
    #
    # @return [self] itself
    #
    def reload(mixin, name, settings)
      signature = @signature.add(name, settings)
      parts     = @parts + @plugins.map { |p| p.call(name, settings) }.compact

      copy do
        @signature = signature
        @parts     = parts

        define_readers(mixin)
        reload_initializer(mixin)
        reload_callback(mixin)
      end
    end

    private

    def copy(&block)
      dup.tap { |instance| instance.instance_eval(&block) }
    end

    def define_readers(mixin)
      readers = @signature.select { |item| item.settings[:reader] != false }
                          .map(&:name)

      mixin.send :attr_reader, *readers if readers.any?
    end

    def reload_initializer(mixin)
      strings = @parts.select { |part| String === part }

      mixin.class_eval <<-RUBY
        def initialize(#{@signature.call})
          #{strings.join("\n")}
          __after_initialize__
        end
      RUBY
    end

    def reload_callback(mixin)
      blocks = @parts.select { |part| Proc === part }

      mixin.send :define_method, :__after_initialize__ do
        blocks.each { |block| instance_eval(&block) }
      end

      mixin.send :private, :__after_initialize__
    end
  end
end
