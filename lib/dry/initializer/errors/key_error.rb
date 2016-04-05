class Dry::Initializer::Errors::KeyError < ::KeyError
  def initialize(*keys)
    super "Unrecognized keys: #{keys.join(", ")}."
  end
end
