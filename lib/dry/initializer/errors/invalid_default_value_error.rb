class Dry::Initializer::Errors::InvalidDefaultValueError < SyntaxError
  def initialize(value)
    super "#{value.inspect} is set directly as a default value." \
          " Wrap it to either proc or lambda."
  end
end
