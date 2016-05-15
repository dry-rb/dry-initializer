class Dry::Initializer::Errors::RedefinitionError < SyntaxError
  def initialize(name)
    super "The argument '#{name}' is already defined."
  end
end
