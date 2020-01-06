module Dry::Initializer
  #
  # @private
  # @abstract
  #
  # Base class for parameter or option definitions
  # Defines methods to add corresponding reader to the class,
  # and build value of instance attribute.
  #
  class Definition
    attr_reader :option, :null, :source, :target, :ivar,
                :type, :optional, :default, :reader,
                :desc

    def options
      {
        as: target,
        type: type,
        optional: optional,
        default: default,
        reader: reader,
        desc: desc
      }.reject { |_, value| value.nil? }
    end

    def name
      @name ||= (option ? 'option' : 'parameter') << " '#{source}'"
    end
    alias to_s    name
    alias to_str  name
    alias inspect name

    def ==(other)
      other.instance_of?(self.class) && (other.source == source)
    end

    def code
      Builders::Reader[self]
    end

    def inch
      @inch ||= (option ? '@option' : '@param ').tap do |text|
        text << ' [Object]'
        text << (option ? " :#{source}" : " #{source}")
        text << (optional ? ' (optional)' : ' (required)')
        text << " #{desc}" if desc
      end
    end

    private

    def initialize(**options)
      @option   = options[:option]
      @null     = options[:null]
      @source   = options[:source]
      @target   = options[:target]
      @ivar     = "@#{@target}"
      @type     = options[:type]
      @reader   = options[:reader]
      @default  = options[:default]
      @optional = options[:optional]
      @desc     = options[:desc]
    end
  end
end
