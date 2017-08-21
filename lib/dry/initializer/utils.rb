# Collection of gem-related utility methods
module Dry::Initializer::Utils
  # Extracts a hash of public params and options assigned to an instance
  #
  # @param  [Dry::Initializer] instance
  # @return [Hash<Symbol, Object]
  #
  def public_options(instance)
    config = instance.class.dry_initializer
    config.each.with_object({}) do |item, obj|
      key = item.target
      next unless instance.respond_to? key
      val = instance.send(key)
      obj[key] = val unless val == config.undefined
    end
  end

  # Extract a hash of variables (params and options) assigned to an instance
  #
  # @param  [Dry::Initializer] instance
  # @return [Hash<Symbol, Object]
  #
  def options(instance)
    config = instance.class.dry_initializer
    config.each.with_object({}) do |item, obj|
      key = item.target
      val = instance.send(:instance_variable_get, item.ivar)
      obj[key] = val unless val == config.undefined
    end
  end
end
