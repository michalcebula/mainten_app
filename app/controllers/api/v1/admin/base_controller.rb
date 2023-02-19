# frozen_string_literal: true

module Api
  module V1
    module Admin
      class BaseController < V1::BaseController
        protect_from_forgery with: :null_session
        before_action :authenticate_request

        private

        def authenticate_request
          decoded_token
          render_unauthorized unless current_user.admin?
        rescue JWT::ExpiredSignature, JWT::DecodeError
          render_unauthorized
        end
      end
    end
  end
end
