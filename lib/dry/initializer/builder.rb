require "set"
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
    # @return [Dry::Initializer::Builder]
    #
    def register(plugin)
      plugins = @plugins + [plugin]
      copy { @plugins = plugins }
    end

    # Defines new agrument and reloads mixin definitions
    #
    # @param [#to_sym] name
    # @param [Hash<Symbol, Object>] settings
    #
    # @return [Dry::Initializer::Builder]
    #
    def define(name, settings)
      signature = @signature.add(name, settings)
      parts     = @parts + @plugins.map { |p| p.call(name, settings) }.compact

      copy do
        @signature = signature
        @parts     = parts
      end
    end

    # Redeclares initializer and readers in the mixin module
    #
    # @param [Module] mixin
    #
    def call(mixin)
      reload_initializer(mixin)
      reload_callback(mixin)
      reload_readers(mixin)
      mixin
    end

    private

    def copy(&block)
      dup.tap { |instance| instance.instance_eval(&block) }
    end

    def reload_initializer(mixin)
      mixin.class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def __initialize__(#{@signature.call})
          @__options__ = __options__
          #{@parts.select { |part| String === part }.join("\n")}
          __after_initialize__
        end
      RUBY

      mixin.send :private, :__initialize__
    end

    def reload_callback(mixin)
      blocks = @parts.select { |part| Proc === part }

      mixin.send :define_method, :__after_initialize__ do
        blocks.each { |block| instance_eval(&block) }
      end

      mixin.send :private, :__after_initialize__
    end

    def reload_readers(mixin)
      @signature.each do |item|
        reload_reader mixin, item.rename, item.settings[:reader]
      end
    end

    def reload_reader(mixin, name, type)
      if type == false
        mixin.undef_method(name) if mixin.instance_methods.include? name.to_sym
      else
        mixin.class_eval <<-RUBY
          def #{name}
            @#{name} unless @#{name} == Dry::Initializer::UNDEFINED
          end
        RUBY

        mixin.send type, name if %w(private protected).include? type.to_s
      end
    end
  end
end
