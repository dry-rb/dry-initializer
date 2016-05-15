class Dry::Initializer::Errors::PluginError < TypeError
  def initialize(plugin)
    super "#{plugin} is not a valid plugin." \
          " Use a subclass of Dry::Initialier::Plugins::Base."
  end
end
