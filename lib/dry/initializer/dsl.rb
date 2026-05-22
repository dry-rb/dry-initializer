# frozen_string_literal: true

module Dry
  module Initializer
    # Module-level DSL
    module DSL
      # Setting for null (undefined value)
      # @return [nil, Dry::Initializer::UNDEFINED]
      attr_reader :null

      # Returns a version of the module with custom settings
      # @option settings [Boolean] :undefined
      #   If unassigned params and options should be treated different from nil
      # @return [Dry::Initializer]
      def [](undefined: true, **)
        null = undefined == false ? nil : UNDEFINED
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
        config.instance_exec(&procedure || block)
        config.mixin.include Mixin::Root
        config.mixin
      end

      private

      def extended(klass)
        null_value = null
        config = Config.new(klass, null: null_value)
        klass.define_singleton_method(:dry_initializer) { config }
        klass.include Mixin::Root
        # `Dry::Initializer#inherited` only fires for classes subclassed
        # *after* the extend. Pre-existing subclasses would otherwise
        # inherit `klass`'s singleton `dry_initializer` and resolve to
        # the parent's Config — so give each one its own Config now.
        klass.subclasses.each { |sub| DSL.install_subclass_config(sub, null_value) }
      end

      class << self
        # @api private
        def install_subclass_config(klass, null_value)
          return if klass.singleton_class.method_defined?(:dry_initializer, false)

          config = Config.new(klass, null: null_value)
          klass.define_singleton_method(:dry_initializer) { config }
          klass.subclasses.each { |sub| install_subclass_config(sub, null_value) }
        end

        private

        def extended(mod)
          mod.instance_variable_set :@null, UNDEFINED
        end
      end
    end
  end
end
