# frozen_string_literal: true

module Dry
  module Initializer
    class CoercionError < ::StandardError
      def initialize(constraint_error, field)
        @constraint_error = constraint_error
        @field = field
        super(message)
      end

      # Ensure that the field name is in the error message
      def message
        if @constraint_error.message =~ /#{@field}/
          @constraint_error.message
        else
          "#{@constraint_error.message} for field :#{@field}"
        end
      end
    end
  end
end
