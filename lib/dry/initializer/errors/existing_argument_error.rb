class Dry::Initializer::Errors::ExistingArgumentError < SyntaxError
  def initialize(name)
    super "the argument '#{name}' is already defined"
  end
end
