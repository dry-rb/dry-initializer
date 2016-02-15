module Dry::Initializer
  # Carries declarations for arguments along with a mixin module
  class Builder
    def arguments
      @arguments ||= Arguments.new
    end

    def mixin
      @mixin ||= Module.new
    end

    # Mutates both [#arguments] and [#mixin] when new definition added
    def call(name, **options)
      @arguments = arguments.add(name, **options)
      mixin.instance_eval @arguments.declaration
    end
  end
end
