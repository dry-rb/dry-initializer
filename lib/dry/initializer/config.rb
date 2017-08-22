module Dry::Initializer
  #
  # Gem-related configuration of some class
  #
  class Config
    # @!attribute [r] undefined
    # @return [Dry::Initializer::UNDEFINED, nil] value of unassigned variable

    # @!attribute [r] klass
    # @return [Class] the class whose config collected by current object

    # @!attribute [r] parent
    # @return [Dry::Initializer::Config] parent configuration

    # @!attribute [r] definitions
    # @return [Hash<Symbol, Dry::Initializer::Definition>]
    #   hash of attribute definitions with their source names

    attr_reader :undefined, :klass, :parent, :definitions

    # List of configs of all subclasses of the [#klass]
    # @return [Array<Dry::Initializer::Config>]
    def children
      ObjectSpace.each_object(Class)
                 .select { |item| item.superclass == klass }
                 .map(&:dry_initializer)
    end

    # List of definitions for initializer params
    # @return [Array<Dry::Initializer::Definition>]
    def params
      definitions.values.reject(&:option)
    end

    # List of definitions for initializer options
    # @return [Array<Dry::Initializer::Definition>]
    def options
      definitions.values.select(&:option)
    end

    # The hash of public attributes for an instance of the [#klass]
    # @param  [Dry::Initializer::Instance] instance
    # @return [Hash<Symbol, Object>]
    def public_attributes(instance)
      unless instance.instance_of? klass
        raise TypeError, "#{instance.inspect} is not an instance of #{klass}"
      end

      definitions.values.each_with_object({}) do |item, obj|
        key = item.target
        next unless instance.respond_to? key
        val = instance.send(key)
        obj[key] = val unless val == undefined
      end
    end

    # The hash of assigned attributes for an instance of the [#klass]
    # @param  [Dry::Initializer::Instance] instance
    # @return [Hash<Symbol, Object>]
    def attributes(instance)
      unless instance.instance_of? klass
        raise TypeError, "#{instance.inspect} is not an instance of #{klass}"
      end

      definitions.values.each_with_object({}) do |item, obj|
        key = item.target
        val = instance.send(:instance_variable_get, item.ivar)
        obj[key] = val unless val == undefined
      end
    end

    # Code of the `#__initialize__` method
    # @return [String]
    def code
      Builders::Initializer[self]
    end

    protected

    # @private
    def finalize
      @definitions = final_definitions
      check_order_of_params

      klass.class_eval(code)

      children.each(&:finalize)
    end

    private

    def initialize(klass = nil)
      @klass       = klass
      sklass       = klass.superclass
      @parent      = sklass.dry_initializer if sklass.is_a? Dry::Initializer
      @undefined   = parent&.undefined
      @definitions = {}
      finalize
    end

    def add_definition(option, name, type, opts)
      definition = Definition.new(option, undefined, name, type, opts)
      definitions[definition.source] = definition
      finalize

      klass.class_eval definition.code
    end

    def final_definitions
      parent_definitions = Hash(parent&.definitions&.dup)
      definitions.each_with_object(parent_definitions) do |(key, val), obj|
        previous = obj[key]
        check_type(previous, val)
        check_constraint(previous, val)
        obj[key] = val
      end
    end

    def check_type(previous, current)
      return unless previous
      return if previous.option == current.option
      raise SyntaxError, "cannot reload #{previous} of #{klass.superclass}" \
                         " by #{current} of its subclass #{klass}"
    end

    def check_constraint(previous, current)
      return unless previous
      return unless previous.default
      return if     current.default
      raise SyntaxError, "cannot reload optional #{previous}" \
                         " of #{klass.superclass}" \
                         " by required #{current} of its subclass #{klass}"
    end

    def check_order_of_params
      params.inject(nil) do |optional, current|
        if current.default
          current
        elsif optional
          raise SyntaxError, "in #{klass} required #{current}" \
                             " goes after optional #{optional}"
        else
          optional
        end
      end
    end
  end
end
