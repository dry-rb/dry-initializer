module Dry::Initializer::Builders
  # @private
  class Reader
    def self.[](definition)
      new(definition).call
    end

    def call
      lines.flatten.compact.join("\n")
    end

    private

    def initialize(definition)
      @target    = definition.target
      @ivar      = definition.ivar
      @undefined = definition.undefined
      @reader    = definition.reader
    end

    def lines
      [undef_line, attribute_line, method_lines, type_line]
    end

    def undef_line
      "undef :#{@target} if method_defined? :#{@target}"
    end

    def attribute_line
      return unless @reader
      "attr_reader :#{@target}" unless @undefined
    end

    def method_lines
      return unless @reader
      return unless @undefined
      [
        "def #{@target}",
        "  #{@ivar} unless #{@ivar} == Dry::Initializer::UNDEFINED",
        "end"
      ]
    end

    def type_line
      "#{@reader} :#{@target}" if %i[private protected].include? @reader
    end
  end
end
