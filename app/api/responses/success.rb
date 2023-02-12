# frozen_string_literal: true

module Responses
  class Success
    include Helpers::Paginable

    DEFAULT_STATUS = :ok

    attr_reader :status, :body, :serializer

    def initialize(status: DEFAULT_STATUS, body: nil, serializer: nil)
      @serializer = serializer
      @body = format(body)
      @status = status.to_sym
    end

    private

    def format(body)
      return {} if body.blank?
      return serializer.new(body) if serializer
      return body if body.key?(:data)

      { data: body }
    end
  end
end
