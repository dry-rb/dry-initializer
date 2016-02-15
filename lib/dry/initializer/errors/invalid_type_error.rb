module Dry::Initializer::Errors
  class InvalidTypeError < ::TypeError
    def initialize(type)
      super "#{type.inspect} doesn't describe a valid type." \
            " Use either a module/class, or an object responding to #call"
    end
  end
end
