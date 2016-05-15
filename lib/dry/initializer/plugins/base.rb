module Dry::Initializer::Plugins
  # Base class for plugins
  #
  # A plugin should has class method [.call] that takes argument name and
  # settings and return a chunk of code for the #initialize method body.
  #
  class Base
    include Dry::Initializer::Errors

    # Builds the proc for the `__after_initializer__` callback
    #
    # @param [#to_s] name
    # @param [Hash<Symbol, Object>] settings
    #
    # @return [String, Proc, nil]
    #
    def self.call(name, settings)
      new(name, settings).call
    end

    # Initializes a builder with argument name and settings
    # @param (see .call)
    def initialize(name, settings)
      @name     = name
      @settings = settings
    end

    # Builds a chunk of code
    # @return (see .call)
    def call
    end

    # @private
    attr_reader :name, :settings
  end
end
