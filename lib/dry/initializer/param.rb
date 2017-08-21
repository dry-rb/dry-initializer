module Dry::Initializer
  # @private
  class Param < Definition
    attr_accessor :position

    def value(instance, params)
      val = (position < params.count) ? params[position] : undefined
      handler.call instance, val
    end

    def inspect
      "parameter '#{target}'"
    end
    alias to_s inspect
    alias to_str inspect
  end
end
