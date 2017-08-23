module Dry::Initializer::Builders
  # @private
  class Initializer
    require_relative "signature"
    require_relative "attribute"

    def self.[](config)
      new(config).call
    end

    def call
      lines.flatten.compact.join("\n")
    end

    private

    def initialize(config)
      @config = config
      @definitions = config.definitions.values
    end

    def lines
      [
        undef_line,
        define_line,
        config_line,
        params_lines,
        options_lines,
        end_line
      ]
    end

    def undef_line
      "undef :__initialize__ if method_defined? :__initialize__"
    end

    def define_line
      "def __initialize__(#{Signature[@config]})"
    end

    def config_line
      return unless @definitions.any? { |item| item.default || item.type }
      "  __config__ = self.class.dry_initializer"
    end

    def params_lines
      @definitions.reject(&:option)
                  .flat_map { |item| Attribute[item] }
                  .map { |line| "  " << line }
    end

    def options_lines
      @definitions.select(&:option)
                  .flat_map { |item| Attribute[item] }
                  .map { |line| "  " << line }
    end

    def end_line
      "end"
    end
  end
end
