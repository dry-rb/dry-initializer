module Dry::Initializer::Builders
  # @private
  class Signature
    def self.[](config)
      new(config).call
    end

    def call
      [
        *required_params,
        *optional_params,
        rest_params,
        *required_options,
        *optional_options,
        rest_options
      ].compact.join(", ")
    end

    private

    def initialize(config)
      @config  = config
      @options = config.options.any?
      @null    = config.null ? 'Dry::Initializer::UNDEFINED' : 'nil'
    end

    def required_params
      @config.params.reject(&:optional).map(&:source)
    end

    def optional_params
      @config.params.select(&:optional).map { |rec| "#{rec.source} = #{@null}" }
    end

    def rest_params
      "*#{@config.rest_params}" if @config.rest_params
    end

    def required_options
      @config.options.reject(&:optional).map { |rec| "#{rec.source}:" }
    end

    def optional_options
      @config.options.select(&:optional).map { |rec| "#{rec.source}: #{@null}" }
    end

    def rest_options
      "**#{@config.rest_options}" if @options && @config.rest_options
    end
  end
end
