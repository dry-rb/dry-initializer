#
# Processes the description of the option/param
#
module Dry::Initializer::Dispatchers::Desc
  module_function

  def call(desc: nil, **options)
    { desc: desc&.to_s&.capitalize, **options }
  end
end
