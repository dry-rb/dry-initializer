module Dry::Initializer
  # @private
  module Mixin
    extend  DSL              # @deprecated
    include Dry::Initializer # @deprecated
    def self.extended(klass) # @deprecated
      warn "[DEPRECATED] Use Dry::Initializer instead of its alias" \
           " Dry::Initializer::Mixin. The later will be removed in v2.1.0"
      super
    end

    require_relative "mixin/root"
    require_relative "mixin/local"
  end
end
