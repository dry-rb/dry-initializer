module Dry::Initializer
  # Shared scope for several params and options
  class Scope
    private

    def initialize(klass, **options)
      @klass   = klass
      @options = options
    end

    def method_missing(name, *args, **options)
      return super unless respond_to? name
      @klass.send(name, *args, **@options.merge(options))
    end

    def respond_to_missing?(name, *)
      @klass.respond_to? name
    end
  end
end
