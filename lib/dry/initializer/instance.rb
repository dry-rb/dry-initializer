module Dry::Initializer
  # @private
  module Instance
    def initialize(*params)
      config    = self.class.dry_initializer
      undefined = config.undefined
      options   = params.pop if config.options.any? && Hash === params.last
      options ||= {}

      if undefined
        config.definitions.each do |item|
          instance_variable_set item.ivar, undefined
        end
      end

      config.params.each do |item|
        value = item.value(self, params)
        instance_variable_set item.ivar, value unless value == undefined
      end

      config.options.each do |item|
        value = item.value(self, options)
        instance_variable_set item.ivar, value unless value == undefined
      end
    end
  end
end
