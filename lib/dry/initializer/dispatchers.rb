module Dry::Initializer
  #
  # @private
  #
  # Dispatchers are responsible for processing arguments
  # of `.param` and `.option` step-by-step.
  #
  # They also allow to add syntax sugar to these methods.
  # New dispatcher should convert the source hash of options into
  # the resulting hash so that you can send additional keys to the helpers.
  #
  # Notice that custom dispatchers are placed on top of the stack,
  # to _pre-process_ options that will be post-processed
  # by standard dispatchers before sending the resulting options
  # to the [Dry::Initializer::Definition].
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
    require_relative "dispatchers/default"
    require_relative "dispatchers/desc"
    require_relative "dispatchers/reader"
    require_relative "dispatchers/source"
    require_relative "dispatchers/target"
    require_relative "dispatchers/type"

    class << self
      def <<(item)
        @list = [item] | list
        self
      end

      def [](**options)
        list.inject(options) { |opts, item| item.call(opts) }
      end

      private

      def list
        @list ||= [Source, Target, Type, Default, Reader, Desc]
      end
    end
  end
end
