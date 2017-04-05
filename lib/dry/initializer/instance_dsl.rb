module Dry::Initializer
  module InstanceDSL
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
