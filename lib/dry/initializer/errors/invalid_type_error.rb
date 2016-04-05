class Dry::Initializer::Errors::InvalidTypeError < ::TypeError
  def initialize(type)
    super "#{type.inspect} doesn't describe a valid type." \
          " Use either a module/class, or an object responding to #call."
  end
end
