class Dry::Initializer::Config
  include Enumerable

  attr_accessor :undefined
  attr_reader   :parent

  def each
    list = all_params + all_options
    block_given? ? list.each { |item| yield(item) } : list.to_enum
  end

  def each_param
    block_given? ? all_params.each { |item| yield(item) } : all_params.to_enum
  end

  def each_option
    block_given? ? all_options.each { |item| yield(item) } : all_options.to_enum
  end

  def param(definition)
    params << definition
  end

  def option(definition)
    options << definition
  end

  private

  def initialize(parent = nil)
    @parent = parent
  end

  def params
    @params ||= []
  end

  def options
    @options ||= []
  end

  def all_params
    list = parent&.send(__method__)&.dup || []
    params.each_with_object(list) do |item, obj|
      item.position = obj.find_index(item) || obj.count
      obj[item.position] = item
    end
  end

  def all_options
    list = parent&.send(__method__)&.dup || []
    options.each_with_object(list) do |item, obj|
      index = obj.find_index(item) || obj.count
      obj[index] = item
    end
  end
end
