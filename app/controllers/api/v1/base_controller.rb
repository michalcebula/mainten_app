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

      def jwt_auth
        Services::Authorization::JWTAuth
      end

      def auth_header
        header = request.headers['Authorization']
        return unless header

        header.split(' ').last
      end

      def render_unauthorized
        render json: { errors: ['unauthorized'] }, status: :unauthorized
      end

      def render_invalid_params
        render json: { errors: ['invalid params'] }, status: :bad_request
      end

      def render_general_error
        render json: { errors: ['something went wrong'] }, status: :internal_server_error
      end

      def current_user
        @current_user = User.find_by(id: decoded_token[:user_id])
      end

      def decoded_token
        @decoded_token ||= jwt_auth.decode(auth_header)
      end

      def user_not_found_response(error)
        return error unless error.is_a?(ActiveRecord::RecordNotFound)

        render json: { errors: [error.message] }, status: :not_found
      end
    end
  end
end
