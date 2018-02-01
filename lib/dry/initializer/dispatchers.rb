module Dry::Initializer
  #
  # @private
  #
  # Dispatchers allow adding syntax sugar to `.param` and `.option` methods.
  #
  # Every dispatcher should convert the source hash of options into
  # the resulting hash so that you can send additional keys to the helpers.
  #
  # @example Add special dispatcher
  #
  #   # Define a dispatcher for key :integer
  #   dispatcher = proc do |opts|
  #     opts.merge(type: proc(&:to_i)) if opts[:integer]
  #   end
  #
  #   # Register a dispatcher
  #   Dry::Initializer::Dispatchers << dispatcher
  #
  #   # Now you can use option `integer: true` instead of `type: proc(&:to_i)`
  #   class Foo
  #     extend Dry::Initializer
  #     param :id, integer: true
  #   end
  #
  module Dispatchers
    class << self
      def <<(item)
        list << item
        self
      end

      def [](options)
        list.inject(options) { |opts, item| item.call(opts) }
      end

      private

      def list
        @list ||= []
      end
    end
  end
end
