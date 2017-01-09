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

    UNDEFINED = Object.new.tap do |obj|
      obj.define_singleton_method :inspect do
        "Dry::Initializer::UNDEFINED"
      end
    end.freeze

    def self.define(proc = nil, &block)
      Module.new do |container|
        container.extend Mixin
        container.instance_exec(&(proc || block))
      end
    end
  end
end
