module Dry::Initializer
  class Param < Definition
    attr_accessor :position

    def value(instance, params)
      value = (position < params.count) ? params[position] : undefined
      super instance, value
    end
  end
end
