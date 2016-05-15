class Dry::Initializer::Errors::OrderError < SyntaxError
  def initialize(name)
    super "Cannot define the required param '#{name}' after optional ones." \
          " Either provide a default value for the '#{name}', or declare it" \
          " before params with default values."
  end
end
