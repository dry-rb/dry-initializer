module Dry::Initializer::Builders
  # @private
  class Signature
    def self.[](config)
      new(config).call
    end

    def call
      (params + star + options).join(", ")
    end

    private

    def initialize(config)
      @config = config
    end

    def null
      @null ||= @config.undefined ? "Dry::Initializer::UNDEFINED" : "nil"
    end

    def params
      @config.params.map do |item|
        item.default ? "#{item.source} = #{null}" : item.source
      end
    end

    def star
      ["*"]
    end

    def options
      @config.options.any? ? ["**__options__"] : []
    end
  end
end
