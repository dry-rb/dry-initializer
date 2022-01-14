module Dry::Initializer::Mixin
  # @private
  module Root
    private

    def initialize(...)
      __dry_initializer_initialize__(...)
    end
  end
end
