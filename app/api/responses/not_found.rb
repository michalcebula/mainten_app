# frozen_string_literal: true

module Responses
  class NotFound < Failure
    ERROR_MESSAGE = 'Not found'

    attr_reader :status, :body

    def initialize(status: :not_found, body: nil, empty: false)
      super
    end
  end
end
