class Dry::Initializer::Errors::KeyError < ::KeyError
  def initialize(*keys)
    super "unrecognized keys: #{keys.join(", ")}"
  end
end
