class Dry::Initializer::Errors::TypeConstraintError < TypeError
  def initialize(name, type)
    super "#{type} is inacceptable constraint for the argument '#{name}'." \
          " Use either plain Ruby module/class, or dry-type."
  end
end
