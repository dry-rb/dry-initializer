class Dry::Initializer::Errors::TypeConstraintError < TypeError
  def initialize(name, type)
    super "#{type} used as constraint for argument '#{name}' is not a dry-type."
  end
end
