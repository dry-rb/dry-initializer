class Dry::Initializer::Errors::MissedDefaultValueError < SyntaxError
  def initialize(name)
    super "you should set a default value for the '#{name}'"
  end
end
