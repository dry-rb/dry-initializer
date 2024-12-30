# frozen_string_literal: true

module Dry
  module Initializer
    module Mixin
      # @private
      module Root
        private

        if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("3.2")
          module_eval(<<~RUBY, __FILE__, __LINE__ + 1)
            def initialize(*, **)
              __dry_initializer_initialize__(*, **)
            end
          RUBY
        else
          def initialize(*args, **kwargs)
            __dry_initializer_initialize__(*args, **kwargs)
          end
        end
      end
    end
  end
end
