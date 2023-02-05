# frozen_string_literal: true

module Dry
  module Initializer
    module Mixin
      # @private
      module Root
        private

        def initialize(args)
          __dry_initializer_initialize__(**args)
        end
      end
    end
  end
end
