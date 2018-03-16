module Dry::Initializer
  # Module-level DSL
  module DSL
    # Setting for null (undefined value)
    # @return [nil, Dry::Initializer::UNDEFINED]
    attr_reader :null

    # Returns a version of the module with custom settings
    # @option settings [Boolean] :undefined
    #   If unassigned params and options should be treated different from nil
    # @return [Dry::Initializer]
    def [](undefined: UNDEFINED, **)
      null = case undefined
             when UNDEFINED then UNDEFINED
             when false     then nil
             when true      then true
             end
      Module.new.tap do |mod|
        mod.extend DSL
        mod.include self
        mod.send(:instance_variable_set, :@null, null)
      end
    end

    # Returns mixin module to be included to target class by hand
    # @return [Module]
    # @yield proc defining params and options
    def define(procedure = nil, &block)
      config = Config.new(null: null)
      config.instance_exec(&(procedure || block))
      config.mixin.include Mixin::Root
      config.mixin
    end

    private

    def extended(klass)
      config = Config.new(klass, null: null)
      klass.send :instance_variable_set, :@dry_initializer, config
      klass.include Mixin::Root
    end

    def self.extended(mod)
      mod.instance_variable_set :@null, UNDEFINED
    end
  end
end
