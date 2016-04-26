module Dry
  # Declares arguments of the initializer (params and options)
  #
  # @api public
  #
  module Initializer

    require_relative "initializer/errors"
    require_relative "initializer/argument"
    require_relative "initializer/arguments"
    require_relative "initializer/builder"
    require_relative "initializer/mixin"

    def self.define(proc = nil, &block)
      Module.new do |container|
        container.extend Dry::Initializer::Mixin
        container.instance_exec(&(proc || block))
      end
    end
  end
end
