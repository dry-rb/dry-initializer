# frozen_string_literal: true

module Dry
  module Initializer
    #
    # Gem-related configuration of some class
    #
    class Config
      # Name of the constant {#finalize} sets on the mixin to hold this
      # Config. Long enough to not collide with user-defined constants.
      CONFIG_CONST = :DRY_INITIALIZER_CONFIG

      # @!attribute [r] null
      # @return [Dry::Initializer::UNDEFINED, nil] value of unassigned variable

      # @!attribute [r] extended_class
      # @return [Class] the class whose config collected by current object

      # @!attribute [r] parent
      # @return [Dry::Initializer::Config] parent configuration

      # @!attribute [r] definitions
      # @return [Hash<Symbol, Dry::Initializer::Definition>]
      #   hash of attribute definitions with their source names

      attr_reader :null, :extended_class, :parent, :definitions

      # @!attribute [r] mixin
      # @return [Module] reference to the module to be included into class
      def mixin
        @mixin ||= Module.new.tap do |mod|
          initializer = self
          mod.set_temporary_name("Dry::Initializer::Mixin::Local[#{extended_class&.inspect}]")
          mod.define_method(:__dry_initializer_config__) do
            initializer
          end
          mod.send :private, :__dry_initializer_config__
        end
      end

      # Configs of {#extended_class}'s direct (one-level) subclasses.
      # Deeper descendants are reached transitively by recursing into each
      # child's own `#children` (as {#compile} does).
      #
      # Skips subclasses that don't have their own `dry_initializer`
      # singleton method yet — they'd inherit ours and we'd recurse into
      # ourselves. `DSL#extended` and `Dry::Initializer#inherited` install
      # those singletons; this guard keeps `#children` correct in between
      # (e.g. while the parent's own Config is still being built).
      #
      # @return [Array<Dry::Initializer::Config>]
      def children
        return [] unless extended_class

        extended_class.subclasses.filter_map do |klass|
          next unless klass.singleton_class.method_defined?(:dry_initializer, false)

          klass.dry_initializer
        end
      end

      # List of definitions for initializer params
      # @return [Array<Dry::Initializer::Definition>]
      def params
        definitions.values.reject(&:option)
      end

      # List of definitions for initializer options
      # @return [Array<Dry::Initializer::Definition>]
      def options
        definitions.values.select(&:option)
      end

      # Adds or redefines a parameter
      # @param  [Symbol]       name
      # @param  [#call, nil]   type (nil)
      # @option opts [Proc]    :default
      # @option opts [Boolean] :optional
      # @option opts [Symbol]  :as
      # @option opts [true, false, :protected, :public, :private] :reader
      # @return [self] itself
      def param(name, type = nil, **opts, &block)
        add_definition(false, name, type, block, **opts)
      end

      # Adds or redefines an option of [#dry_initializer]
      #
      # @param  (see #param)
      # @option (see #param)
      # @return (see #param)
      #
      def option(name, type = nil, **opts, &block)
        add_definition(true, name, type, block, **opts)
      end

      # The hash of public attributes for an instance of the [#extended_class]
      # @param  [Dry::Initializer::Instance] instance
      # @return [Hash<Symbol, Object>]
      def public_attributes(instance)
        definitions.values.each_with_object({}) do |item, obj|
          key = item.target
          next unless instance.respond_to? key

          val = instance.send(key)
          obj[key] = val unless null == val
        end
      end

      # The hash of assigned attributes for an instance of the [#extended_class]
      # @param  [Dry::Initializer::Instance] instance
      # @return [Hash<Symbol, Object>]
      def attributes(instance)
        definitions.values.each_with_object({}) do |item, obj|
          key = item.target
          val = instance.send(:instance_variable_get, item.ivar)
          obj[key] = val unless null == val
        end
      end

      # Code of the `#__initialize__` method
      # @return [String]
      def code
        Builders::Initializer[self]
      end

      # Seal the config. After finalize the class is usable from non-main
      # Ractors and the Config (with its definitions) is deeply frozen —
      # further `param`/`option` calls raise `FrozenError`.
      #
      # @return [self]
      def finalize
        return self if @finalized

        compile

        mixin.const_set(CONFIG_CONST, self) unless mixin.const_defined?(CONFIG_CONST, false)
        mixin.send(:undef_method, :__dry_initializer_config__) \
          if mixin.private_method_defined?(:__dry_initializer_config__)
        mixin.module_eval(<<~RUBY, __FILE__, __LINE__ + 1)
          private def __dry_initializer_config__
            #{CONFIG_CONST}
          end
        RUBY

        # Replace the bmethod `klass.dry_initializer` from `DSL#extended`
        # / `Dry::Initializer#inherited` with a `def` reading the mixin
        # constant, so it's callable from any Ractor.
        if extended_class
          extended_class.singleton_class.send(:undef_method, :dry_initializer) \
            if extended_class.singleton_class.method_defined?(:dry_initializer, false)
          extended_class.class_eval(<<~RUBY, __FILE__, __LINE__ + 1)
            def self.dry_initializer
              #{CONFIG_CONST}
            end
          RUBY
        end

        @finalized = true
        Ractor.make_shareable(self) if defined?(Ractor)
        self
      end

      # Human-readable representation of configured params and options
      # @return [String]
      def inch
        line  =  Builders::Signature[self]
        line  =  line.gsub("__dry_initializer_options__", "options")
        lines =  ["@!method initialize(#{line})"]
        lines += ["Initializes an instance of #{extended_class}"]
        lines += definitions.values.map(&:inch)
        lines += ["@return [#{extended_class}]"]
        lines.join("\n")
      end

      protected

      # Rebuild the generated initializer on the mixin and recurse into
      # children. Called on every DSL change. Protected — it makes no
      # Ractor-readiness guarantees (only {#finalize} does), but the
      # recompile chain crosses sibling Config instances.
      # @return [self]
      def compile
        @definitions = final_definitions
        check_order_of_params
        mixin.class_eval(code, "#{__FILE__}:#{__LINE__} class_eval")
        children.each { |child| child.compile }
        self
      end

      private

      def initialize(extended_class = nil, null: UNDEFINED)
        @extended_class = extended_class
        sklass          = extended_class&.superclass
        @parent         = sklass.dry_initializer if sklass.is_a? Dry::Initializer
        @null           = null || parent&.null
        @definitions    = {}
        extended_class&.include(mixin)
        compile
      end

      def add_definition(option, name, type, block, **opts)
        opts = {
          parent: extended_class,
          option:,
          null:,
          source: name,
          type:,
          block:,
          **opts
        }

        options = Dispatchers.call(**opts)
        definition = Definition.new(**options)
        definitions[definition.source] = definition
        compile
        mixin.class_eval definition.code
      end

      def final_definitions
        parent_definitions = Hash(parent&.definitions&.dup)
        definitions.each_with_object(parent_definitions) do |(key, val), obj|
          obj[key] = check_type(obj[key], val)
        end
      end

      def check_type(previous, current)
        return current unless previous
        return current if previous.option == current.option

        raise SyntaxError,
              "cannot reload #{previous} of #{extended_class.superclass}" \
              " by #{current} of its subclass #{extended_class}"
      end

      def check_order_of_params
        params.inject(nil) do |optional, current|
          if current.optional
            current
          elsif optional
            raise SyntaxError, "#{extended_class}: required #{current}" \
                               " goes after optional #{optional}"
          else
            optional
          end
        end
      end
    end
  end
end
