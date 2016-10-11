module Dry::Initializer
  # Shared scope for several params and options
  class Scope
    # Defines param with shared settings
    #
    # @param  (see Dry::Initializer::Mixin#param)
    # @option (see Dry::Initializer::Mixin#param)
    # @return (see Dry::Initializer::Mixin#param)
    #
    def param(name, **options)
      @klass.param name, @options.merge(options)
    end

    # Defines option with shared settings
    #
    # @param  (see Dry::Initializer::Mixin#option)
    # @option (see Dry::Initializer::Mixin#option)
    # @return (see Dry::Initializer::Mixin#option)
    #
    def option(name, **options)
      @klass.option name, @options.merge(options)
    end

    private

    def initialize(klass, **options)
      @klass   = klass
      @options = options
    end
  end
end
