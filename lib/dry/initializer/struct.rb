#
# The nested structure that takes nested hashes with indifferent access
#
class Dry::Initializer::Struct
  extend Dry::Initializer

  class << self
    undef_method :param

    def new(options)
      super Hash(options).transform_keys(&:to_sym)
    end
    alias call new
  end

  #
  # Represents event data as a nested hash with deeply stringified keys
  # @return [Hash<String, ...>]
  #
  def to_h
    self
      .class
      .dry_initializer
      .attributes(self)
      .transform_values { |v| __hashify(v) }
      .stringify_keys
  end

  private

  def __hashify(value)
    case value
    when Hash
      value.each_with_object({}) { |(k, v), obj| obj[k.to_s] = __hashify(v) }
    when Array then value.map { |v| __hashify(v) }
    when Dry::Initializer::Struct then value.to_h
    else value
    end
  end
end
