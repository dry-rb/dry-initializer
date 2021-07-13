module Dry::Initializer::Mixin
  # @private
  module Root
    private

    def initialize(*args, **kwargs)
      puts "root initialize: #{args}, #{kwargs}"
      if kwargs.empty?
        __dry_initializer_initialize__(*args)
      else
        __dry_initializer_initialize__(*args, **kwargs)
      end
    end
  end
end
