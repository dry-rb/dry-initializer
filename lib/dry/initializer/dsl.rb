module Dry::Initializer
  module DSL
    attr_reader :config

    def [](**settings)
      Module.new do
        extend  Dry::Initializer::DSL
        include Dry::Initializer
        @config = settings
      end
    end

    def define(fn = nil, &block)
      mixin = Module.new do
        def initialize(*args)
          __initialize__(*args)
        end
      end

      builder = Builder.new
      builder.instance_exec(&(fn || block))
      builder.call(mixin)
      mixin
    end

    private

    def extended(klass)
      super
      mixin   = klass.send(:__initializer_mixin__)
      builder = klass.send(:__initializer_builder__, Hash(config))

      builder.call(mixin)
      klass.include(mixin)
      klass.send(:define_method, :initialize) do |*args|
        __initialize__(*args)
      end
    end

    def mixin(fn = nil, &block)
      define(fn, &block)
    end
  end
end
