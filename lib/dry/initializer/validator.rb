module Dry::Initializer
  module Validator
    extend self

    def call(klass)
      leafs(klass).each { |item| check_params_of(item) }
    end

    private

    def descentants(klass)
      ObjectSpace.each_object(Class).select { |item| item.superclass == klass }
    end

    def leafs(klass)
      list = descentants(klass)
      list.empty? ? [klass] : list.flat_map { |item| leafs(item) }
    end

    def check_params_of(klass)
      klass.dry_initializer.params.inject(nil) do |default, current|
        if current.default
          current
        elsif default
          raise_error(klass, default, current)
        end
      end
    end

    def raise_error(klass, default, current)
      raise ArgumentError,
            "#{klass} contains required #{current} after optional #{default}"
    end
  end
end
