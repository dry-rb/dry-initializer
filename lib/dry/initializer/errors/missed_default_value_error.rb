class Dry::Initializer::Errors::MissedDefaultValueError < SyntaxError
  def initialize(name)
    super "You should set a default value for the '#{name}'."
  end
end
