class Dry::Initializer::Errors::TypeError < TypeError
  def initialize(name, type, value)
    super "A value #{value.inspect} assigned to the argument '#{name}'" \
          " mismatches type constraint: #{type}."
  end
end
