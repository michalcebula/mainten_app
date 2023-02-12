# frozen_string_literal: true

module Responses
  class Unpermitted < Failure
    ERROR_MESSAGE = 'Unpermitted'

    attr_reader :status, :body

    def initialize(status: :forbidden, body: nil, empty: false)
      super
    end
  end
end
