module Dry::Initializer
  # @private
  module Instance
    def initialize(*params)
      config  = self.class.dry_initializer
      null    = config.undefined
      options = params.pop if config.options.any? && Hash === params.last
      options ||= {}

      config.ivars.each { |ivar| instance_variable_set ivar, null } if null

      config.params.each do |item|
        value = item.value(self, params)
        instance_variable_set item.ivar, value unless value == null
      end

      config.options.each do |item|
        value = item.value(self, options)
        instance_variable_set item.ivar, value unless value == null
      end
    end
  end
end
