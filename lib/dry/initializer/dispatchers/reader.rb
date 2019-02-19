#
# Checks the `:reader`
#
module Dry::Initializer::Dispatchers::Reader
  module_function

  def call(reader: :public, **options)
    reader = \
      case reader.to_s
      when "", "false" then false
      when "private"   then :private
      when "protected" then :protected
      else :public
      end

    { reader: reader, **options }
  end
end
