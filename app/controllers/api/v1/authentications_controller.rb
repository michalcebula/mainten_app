# frozen_string_literal: true

module Api
  module V1
    class AuthenticationsController < Api::V1::BaseController
      skip_before_action :authenticate_request, only: [:create]

      def create
        @user = find_user_by_username
        return render json: { token: }, status: :ok if @user && @user.authenticate(permitted_params[:password])
        
        render_unauthorized
      end

      def destroy
        jwt_auth.expire(auth_header)

        head :ok
      end

      private

      def find_user_by_username
        User.find_by(username: permitted_params[:username])
      end

      def permitted_params
        params.permit(%I[username password])
      end

      def token
        jwt_auth.encode(user_id: @user.id)
      end
    end
  end
end
