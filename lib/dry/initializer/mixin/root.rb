module Dry::Initializer::Mixin
  # @private
  module Root
    private

    def initialize(*args)
      __dry_initializer_initialize__(*args)
    end
  end
end
