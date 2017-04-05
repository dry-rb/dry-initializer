module Dry::Initializer
  module ClassDSL
    attr_reader :config

    def [](**settings)
      Module.new do
        extend  Dry::Initializer::ClassDSL
        include Dry::Initializer
        @config = settings
      end
    end

    def define(fn = nil, &block)
      mixin   = Module.new { include InstanceDSL }
      builder = Builder.new Hash(config)
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

      klass.include(InstanceDSL) # defines #initialize
      klass.include(mixin)       # defines #__initialize__ (to be redefined)
    end

    def mixin(fn = nil, &block)
      define(fn, &block)
    end
  end
end
