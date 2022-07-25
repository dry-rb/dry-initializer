# frozen_string_literal: true

# Prepares the `:default` option
#
# It must respond to `.call` without arguments
#
module Dry
  module Initializer
    module Dispatchers
      module PrepareDefault
        extend self

        def call(default: nil, optional: nil, **options)
          default = callable! default
          check_arity! default

          {default: default, optional: (optional | default), **options}
        end

        private

        def callable!(default)
          return unless default
          return default if default.respond_to?(:call)
          return callable(default.to_proc) if default.respond_to?(:to_proc)

          invalid!(default)
        end

        def check_arity!(default)
          return unless default

          arity = default.is_a?(Proc) ? default.arity : default.method(:call).arity
          return if arity.equal?(0) || arity.equal?(-1)

          invalid!(default)
        end

        def invalid!(default)
          raise TypeError, "The #{default.inspect} should be" \
                           " either convertable to proc with no arguments," \
                           " or respond to #call without arguments."
        end
      end
    end
  end
end
