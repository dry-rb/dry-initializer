module Dry::Initializer
  # Immutable container for chunks of code describing argument signatures.
  # Responcible for building the resulting signature for the initializer args.
  class Signature
    include Enumerable
    include Errors

    def initialize(*list)
      @list = list
    end

    def add(*args)
      signature = Plugins::Signature.new(*args)

      validate_order_of signature
      validate_param_uniqueness_of signature
      validate_option_uniqueness_of signature
      validate_attribute_uniqueness_of signature

      self.class.new(*@list, signature)
    end

    def each
      @list.each { |item| yield item }
    end

    def call
      options = all?(&:param?) ? %w(__options__={}) : %w(**__options__)
      (select(&:param?).map(&:call) + options).compact.join(", ")
    end

    private

    def validate_param_uniqueness_of(signature)
      return unless signature.param?
      return unless select(&:param?).map(&:name).include? signature.name

      fail RedefinitionError.new(signature.name)
    end

    def validate_option_uniqueness_of(signature)
      return if signature.param?
      return unless reject(&:param?).map(&:name).include? signature.name

      fail RedefinitionError.new(signature.name)
    end

    def validate_attribute_uniqueness_of(signature)
      return unless map(&:rename).include? signature.rename

      fail RedefinitionError.new(signature.name)
    end

    def validate_order_of(signature)
      return unless signature.required? && signature.param?
      return unless reject(&:required?).any?(&:param?)

      fail OrderError.new(signature.name)
    end
  end
end
