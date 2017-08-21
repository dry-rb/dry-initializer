module Dry::Initializer
  # @private
  module Extension
    attr_accessor :settings

    def extended(klass)
      klass.include Instance

      unless settings.to_h[:undefined] == false
        klass.dry_initializer.send :instance_variable_set,
                                   :@undefined,
                                   UNDEFINED
      end

      super
    end
  end
end
