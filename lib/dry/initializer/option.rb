module Dry::Initializer
  class Option < Definition
    def value(instance, options)
      super instance, options.fetch(source, undefined)
    end
  end
end
