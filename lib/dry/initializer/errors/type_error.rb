class Dry::Initializer::Errors::TypeError < ::TypeError
  def initialize(type, value)
    super "#{value.inspect} mismatches the type #{type}"
  end
end
