module Dry
  # Declares arguments of the initializer (params and options)
  #
  # @api public
  #
  module Initializer
    require_relative "initializer/errors"
    require_relative "initializer/plugins"
    require_relative "initializer/signature"
    require_relative "initializer/builder"
    require_relative "initializer/mixin"

    UNDEFINED = Object.new.freeze

    def self.define(proc = nil, &block)
      Module.new do |container|
        container.extend Mixin
        container.instance_exec(&(proc || block))
      end
    end
  end
end
