# frozen_string_literal: true

module Responses
  class BadRequest < Failure
    ERROR_MESSAGE = 'Invalid params'

    attr_reader :status, :body

    def initialize(status: :bad_request, body: nil, empty: false)
      super
    end
  end
end
