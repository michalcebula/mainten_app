# frozen_string_literal: true

module Responses
  class Failure
    ERROR_MESSAGE = 'Something went wrong'

    attr_reader :status, :body

    def initialize(status: :internal_server_error, body: nil, empty: false)
      @empty = empty
      @status = status.to_sym
      @body = body.blank? ? format(self.class::ERROR_MESSAGE) : format(body)
    end

    private

    def format(body)
      return {} if @empty
      return { errors: body, status: status.to_s } if body.is_a?(Array)

      { errors: [body], status: status.to_s }
    end
  end
end
