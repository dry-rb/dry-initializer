module Dry::Initializer
  class Option < Definition
    def value(instance, options)
      super instance, options.fetch(source, undefined)
    end

    def inspect
      "options '#{target}'"
    end
    alias to_s inspect
    alias to_str inspect
  end
end
