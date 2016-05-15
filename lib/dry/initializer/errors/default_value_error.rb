class Dry::Initializer::Errors::DefaultValueError < TypeError
  def initialize(name, value)
    super "Cannot set #{value.inspect} directly as a default value" \
          " of the argument '#{name}'. Wrap it to either proc or lambda."
  end
end
