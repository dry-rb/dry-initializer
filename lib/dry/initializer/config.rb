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

    # @!attribute [r] params
    # @return [Dry::Initializer::Param]
    #   list of definitions for initializer options

    # @!attribute [r] options
    # @return [Dry::Initializer::Option]
    #   list of definitions for initializer options

    # @!attribute [r] all
    # @return [Dry::Initializer::Definition]
    #   list of all [#params] and [#options]

    attr_reader :undefined, :klass, :parent, :params, :options, :all

    # The list of configs of all subclasses of the [#klass]
    #
    # @return [Array<Dry::Initializer::Config>]
    #
    def children
      ObjectSpace.each_object(Class)
                 .select { |item| item.superclass == klass }
                 .map(&:dry_initializer)
    end

    # The hash of public attributes for an instance of the [#klass]
    #
    # @param  [Dry::Initializer::Instance] instance
    # @return [Hash<Symbol, Object>]
    #
    def public_attributes(instance)
      unless instance.instance_of? klass
        raise TypeError, "#{instance.inspect} is not an instance of #{klass}"
      end

      all.each_with_object({}) do |item, obj|
        key = item.target
        next unless instance.respond_to? key
        val = instance.send(key)
        obj[key] = val unless val == undefined
      end
    end

    # The hash of assigned attributes for an instance of the [#klass]
    #
    # @param  [Dry::Initializer::Instance] instance
    # @return [Hash<Symbol, Object>]
    #
    def attributes(instance)
      unless instance.instance_of? klass
        raise TypeError, "#{instance.inspect} is not an instance of #{klass}"
      end

      all.each_with_object({}) do |item, obj|
        key = item.target
        val = instance.send(:instance_variable_get, item.ivar)
        obj[key] = val unless val == undefined
      end
    end

    protected

    # @private
    def finalize
      @params  = final_params
      @options = final_options
      @all     = @params + @options
      check_params
      children.each(&:finalize)
    end

    private

    def initialize(klass = nil)
      @klass     = klass
      sklass     = klass.superclass
      @parent    = sklass.dry_initializer if sklass.is_a? Dry::Initializer
      @undefined = parent&.undefined
      @params    = []
      @options   = []
      @all       = @params + @options
    end

    def add_param(definition)
      params << definition
      finalize
    end

    def add_option(definition)
      options << definition
      finalize
    end

    def final_params
      list = parent&.params&.dup || []
      params.each_with_object(list) do |item, obj|
        item.position = obj.find_index(item) || obj.count
        obj[item.position] = item
      end
    end

    def final_options
      list = parent&.options&.dup || []
      options.each_with_object(list) do |item, obj|
        index = obj.find_index(item) || obj.count
        obj[index] = item
      end
    end

    def check_params
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
