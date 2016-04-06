module Dry::Initializer
  # Collection of definitions for arguments
  #
  # @api private
  #
  class Arguments
    include Errors
    include Enumerable

    def initialize(**arguments)
      @arguments = arguments
    end

    def add(name, options)
      validate_uniqueness(name)
      validate_presence_of_default(name, options)

      new_argument = Argument.new(name, options)
      self.class.new @arguments.merge(name.to_sym => new_argument)
    end

    def declaration
      <<-RUBY
        attr_reader #{select(&:reader).map { |arg| ":#{arg.name}" }.join(", ")}
        define_method :initialize do |#{signature}|
          #{assign_arguments}
          #{take_declarations}
          #{assign_defaults}
          #{check_constraints}
        end
      RUBY
    end

    def [](name)
      @arguments[name]
    end

    private

    def each
      @arguments.each { |_, argument| yield(argument) }
    end

    def params
      reject(&:option)
    end

    def options
      select(&:option)
    end

    def validate_uniqueness(name)
      fail ExistingArgumentError.new(name) if self[name.to_sym]
    end

    def validate_presence_of_default(name, options)
      return if options.key? :default
      return if options[:option]
      return unless params.any?(&:default)

      fail MissedDefaultValueError.new(name)
    end

    def signature
      (params + options).map(&:signature).join(", ")
    end

    def assign_arguments
      map(&:assignment).join("\n")
    end

    def take_declarations
      return unless any?(&:default) || any?(&:type)
      "__arguments__ = self.class.send(:arguments_builder).arguments"
    end

    def assign_defaults
      select(&:default).map(&:default_assignment).join("\n")
    end

    def check_constraints
      select(&:type).map(&:type_constraint).join("\n")
    end
  end
end
