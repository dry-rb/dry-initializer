# frozen_string_literal: true

module Dry
  module Initializer
    module Mixin
      # @private
      module Root
        private

        def initialize(...)
          __dry_initializer_initialize__(...)
        end
      end
    end
  end
end
