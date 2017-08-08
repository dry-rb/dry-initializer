module Dry::Initializer
  module InstanceDSL
    def dry_initializer_options
      h = @__dry_initializer_options__.map do |accessor, _|
        [accessor, public_send(accessor)] if respond_to?(accessor)
      end
      h.compact.to_h
    end

    private

    # The method is reloaded explicitly
    # in a class that extend [Dry::Initializer], or in its subclasses.
    def initialize(*args)
      __initialize__(*args)
    end

    # The method is redefined implicitly every time
    # a `param` or `option` is invoked.
    def __initialize__(*); end
  end
end
