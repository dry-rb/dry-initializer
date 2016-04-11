module Dry::Initializer
  # Carries declarations for arguments along with a mixin module
  #
  # @api private
  #
  class Builder
    def arguments
      @arguments ||= Arguments.new
    end

    def mixin
      @mixin ||= Module.new
    end

    def define_initializer(name, **options)
      @arguments = arguments.add(name, **options)
      mixin.instance_eval @arguments.declaration
    end

    def define_attributes_reader(name, keys)
      symbol_keys = keys.map { |key| ":" << key.to_s }.join(", ")
      key = '@#{key}'

      mixin.class_eval <<-RUBY
        def #{name}
          [#{symbol_keys}].inject({}) do |hash, key|
            hash.merge key => instance_variable_get(:"#{key}")
          end
        end
      RUBY
    end
  end
end