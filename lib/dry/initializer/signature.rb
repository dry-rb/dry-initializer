module Dry::Initializer
  # Immutable container for chunks of code describing argument signatures.
  # Responcible for building the resulting signature for the initializer args.
  class Signature
    include Enumerable
    include Errors

    def initialize
      @list = []
    end

    def add(*args)
      signature = Plugins::Signature.new(*args)

      validates_uniqueness_of signature
      validates_order_of signature

      copy { @list += [signature] }
    end

    def each
      (@list.select(&:param?) + @list.reject(&:param?)).each do |item|
        yield item
      end
    end

    def call
      map(&:call).join(", ")
    end

    private

    def copy(&block)
      dup.tap do |instance|
        instance.instance_eval(&block)
      end
    end

    def validates_uniqueness_of(signature)
      return unless include? signature

      fail RedefinitionError.new(signature.name)
    end

    def validates_order_of(signature)
      return unless signature.param? && !signature.default?
      return unless any? { |item| item.param? && item.default? }

      fail OrderError.new(signature.name)
    end
  end
end
