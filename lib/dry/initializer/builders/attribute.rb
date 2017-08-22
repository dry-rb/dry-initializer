module Dry::Initializer::Builders
  # @private
  class Attribute
    def self.[](definition)
      new(definition).call
    end

    def call
      lines.compact
    end

    private

    def initialize(definition)
      @definition = definition
    end

    def name
      @name ||= @definition.option ? "__value__" : "#{@definition.source}"
    end

    def null
      @null ||= @definition.null ? "Dry::Initializer::UNDEFINED" : "nil"
    end

    def undefined
      @undefined ||= case @definition.null
                     when nil then "#{name}.nil?"
                     else "#{name} == Dry::Initializer::UNDEFINED"
                     end
    end

    def lines
      [
        "",
        definition_line,
        reader_line,
        default_line,
        coercion_line,
        assignment_line
      ]
    end

    def reader_line
      return unless @definition.option
      @definition.default ? optional_reader : required_reader
    end

    def optional_reader
      "#{name} = __options__.fetch(:'#{@definition.source}', #{null})"
    end

    def required_reader
      "#{name} = __options__.fetch(:'#{@definition.source}')" \
      " { raise KeyError, \"\#{self.class}: #{@definition} is required\" }"
    end

    def definition_line
      return unless @definition.type || @definition.default
      "__definition__ = __config__.definitions[:'#{@definition.source}']"
    end

    def default_line
      return unless @definition.default
      "#{name} = instance_exec(&__definition__.default) if #{undefined}"
    end

    def coercion_line
      return unless @definition.type
      "#{name} = __definition__.type.call(#{name}) unless #{undefined}"
    end

    def assignment_line
      "#{@definition.ivar} = #{name} unless #{undefined}"
    end
  end
end
