require "pry"

module Dry::Initializer
  module Instance
    def initialize(*params)
      config  = self.class.dry_initializer
      options = params.pop if config.any?(&:option?) && Hash === params.last
      options ||= {}

      if config.undefined
        config.each { |item| instance_variable_set item.ivar, config.undefined }
      end

      config.each_param do |item|
        value = item.value(self, params)
        instance_variable_set item.ivar, value unless value == item.undefined
      end

      config.each_option do |item|
        value = item.value(self, options)
        instance_variable_set item.ivar, value unless value == item.undefined
      end
    end
  end
end
