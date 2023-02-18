# frozen_string_literal: true

module Api
  module V1
    class BaseController < ApplicationController
      include Helpers::Paginable

      protect_from_forgery with: :null_session
      before_action :authenticate_request

      private

      def authenticate_request
        decoded_token
      rescue JWT::ExpiredSignature, JWT::DecodeError
        render_unauthorized
      end

      def current_user
        @current_user ||= UserRepository.find_current_user(decoded_token[:user_id])
      end

      def jwt_auth
        Services::Authorization::JWTAuth
      end

      def auth_header
        header = request.headers['Authorization']
        return unless header

        header.split(' ').last
      end

      def decoded_token
        @decoded_token ||= jwt_auth.decode(auth_header)
      end

      def render_response(status: :ok, body: nil, serializer: nil, paginated: false)
        response = Responses::Success.new(status:, body:, serializer:)
        response = Responses::Success.new(status:, body: paginate(body, serializer:)) if paginated

        render json: response.body, status: response.status
      end

      def render_unauthorized
        response = Responses::Unauthorized.new
        render json: response.body, status: response.status
      end

      def render_invalid_params
        response = Responses::BadRequest.new
        render json: response.body, status: response.status
      end

      def render_general_error
        response = Responses::Failure.new
        render json: response.body, status: response.status
      end

      def user_not_found_response(error)
        return error unless error.is_a?(ActiveRecord::RecordNotFound)

        response = Responses::NotFound.new(body: error.message)
        render json: response.body, status: response.status
      end
    end
  end
end
