#
# Prepares the target name of a parameter or an option.
#
# Unlike source, the target must satisfy requirements for Ruby variable names.
# It also shouldn't be in conflict with names used by the gem.
#
module Dry::Initializer::Dispatchers::Target
  module_function

  # Regex to check if the target name is allowed
  ALLOWED = /\A[a-z_][a-z0-9_]*\z/

  # List of variable names reserved by the gem
  RESERVED = %i[
    __dry_initializer_options__
    __dry_initializer_config__
    __dry_initializer_value__
    __dry_initializer_definition__
    __dry_initializer_initializer__
  ].freeze

  def call(source:, target: nil, as: nil, **options)
    target ||= as || source
    target = target.to_s.to_sym

    unless target[ALLOWED]
      raise "The name `@#{target}` is not allowed for Ruby variables"
    end

    if RESERVED.include?(target)
      raise "The name `@#{target}` is reserved by the dry-initializer gem"
    end

    { source: source, target: target, ivar: :"@#{target}", **options }
  end
end
