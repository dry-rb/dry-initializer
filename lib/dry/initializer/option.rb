module Dry::Initializer
  # @private
  class Option < Definition
    def value(instance, options)
      val = options.fetch(source, undefined)
      handler.call instance, val
    end

    def inspect
      "options '#{target}'"
    end
    alias to_s inspect
    alias to_str inspect
  end
end
