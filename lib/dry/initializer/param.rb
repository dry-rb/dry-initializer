module Dry::Initializer
  class Param < Definition
    attr_accessor :position

    def value(instance, params)
      value = (position < params.count) ? params[position] : undefined
      super instance, value
    end

    def inspect
      "parameter '#{target}'"
    end
    alias to_s inspect
    alias to_str inspect
  end
end
