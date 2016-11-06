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

      validates_uniqueness_of signature
      validates_order_of signature

      self.class.new(*@list, signature)
    end

    def each
      @list.each { |item| yield item }
    end

    def call
      (select(&:param?).map(&:call) + %w(**__options__)).compact.join(", ")
    end

    private

    def validates_uniqueness_of(signature)
      return unless include? signature

      fail RedefinitionError.new(signature.name)
    end

    def validates_order_of(signature)
      return unless signature.required? && signature.param?
      return unless reject(&:required?).any?(&:param?)

      fail OrderError.new(signature.name)
    end
  end
end
