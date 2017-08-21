class Dry::Initializer::Config
  attr_accessor :undefined
  attr_reader   :klass

  def parent
    return unless klass.superclass.ancestors.include? Dry::Initializer::Instance
    @parent ||= klass.superclass.dry_initializer
  end

  def children
    ObjectSpace.each_object(Class)
               .select { |item| item.superclass == klass }
               .map(&:dry_initializer)
  end

  def params
    @params ||= []
  end

  def options
    @options ||= []
  end

  def all
    @all ||= @params + @options
  end

  def param(definition)
    params << definition
    finalize
  end

  def option(definition)
    options << definition
    finalize
  end

  def finalize
    @params  = final_params
    @options = final_options
    @all     = @params + @options
    children.each(&:finalize)
    self
  end

  private

  def initialize(klass = nil)
    @klass = klass
    @undefined = parent&.undefined
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
end
