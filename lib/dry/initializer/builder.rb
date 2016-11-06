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
      define_readers(mixin)
      reload_initializer(mixin)
      reload_callback(mixin)
      mixin
    end

    private

    def copy(&block)
      dup.tap { |instance| instance.instance_eval(&block) }
    end

    def define_readers(mixin)
      define_reader(
        mixin,
        :attr_reader,
        ->(item) { item.settings[:reader] != false }
      )
      define_reader mixin, :private
      define_reader mixin, :protected
    end

    def define_reader(mixin, method, filter_lambda = nil)
      filter_lambda ||= ->(item) { item.settings[:reader] == method }
      readers = @signature.select(&filter_lambda).map(&:rename)
      mixin.send method, *readers if readers.any?
    end

    def reload_initializer(mixin)
      mixin.class_eval <<-RUBY
        def initialize(#{@signature.call})
          #{@parts.select { |part| String === part }.join("\n")}
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
