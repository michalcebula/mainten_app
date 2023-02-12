# frozen_string_literal: true

module Responses
  class Unauthorized < Failure
    ERROR_MESSAGE = 'Unauthorized'

    attr_reader :status, :body

    def initialize(status: :unauthorized, body: nil, empty: false)
      super
    end
  end
end
