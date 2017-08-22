module Dry::Initializer
  # @private
  module Instance
    def initialize(*args)
      __initialize__(*args)
    end
  end
end
