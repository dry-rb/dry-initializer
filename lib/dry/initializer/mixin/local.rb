module Dry::Initializer::Mixin
  # @private
  module Local
    attr_reader :klass

    def inspect
      "Dry::Initializer::Mixin::Local[#{klass}]"
    end
    alias to_s   inspect
    alias to_str inspect

    private

    def included(klass)
      @klass = klass
      super
    end
  end
end
