module Dry::Initializer
  module Instance
    def initialize(*params)
      config  = self.class.dry_initializer
      options = params.pop if config.options.any? && Hash === params.last
      options ||= {}

      if config.undefined
        config.all.each do |item|
          instance_variable_set item.ivar, config.undefined
        end
      end

      config.params.each do |item|
        value = item.value(self, params)
        instance_variable_set item.ivar, value unless value == item.undefined
      end

      config.options.each do |item|
        value = item.value(self, options)
        instance_variable_set item.ivar, value unless value == item.undefined
      end
    end
  end
end
