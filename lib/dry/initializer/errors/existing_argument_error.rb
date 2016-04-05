class Dry::Initializer::Errors::ExistingArgumentError < SyntaxError
  def initialize(name)
    super "The argument '#{name}' is already defined."
  end
end
