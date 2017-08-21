module Dry::Initializer
  class Config
    attr_reader :undefined, :klass, :parent, :params, :options, :all

    def children
      ObjectSpace.each_object(Class)
                 .select { |item| item.superclass == klass }
                 .map(&:dry_initializer)
    end

    def param(definition)
      params << definition
      finalize
    end

    def option(definition)
      options << definition
      finalize
    end

    def public_attributes(instance)
      all.each_with_object({}) do |item, obj|
        key = item.target
        next unless instance.respond_to? key
        val = instance.send(key)
        obj[key] = val unless val == undefined
      end
    end

    def attributes(instance)
      all.each_with_object({}) do |item, obj|
        key = item.target
        val = instance.send(:instance_variable_get, item.ivar)
        obj[key] = val unless val == undefined
      end
    end

    protected

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
