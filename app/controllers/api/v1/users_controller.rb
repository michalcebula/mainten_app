# frozen_string_literal: true

module Api
  module V1
    class UsersController < Api::V1::BaseController
      skip_before_action :authenticate_request, only: [:create]

      def index
        users = User.all
        render json: users, status: :ok
      end

      def show
        user = User.find(user_id[:id])

        render json: user, status: :ok
      rescue ActiveRecord::RecordNotFound => e
        user_not_found_response(e)
      end

      def create
        user = User.new(user_params)
        return render json: user, status: :created if user.save

        render json: user_validation_errors(user), status: :unprocessable_entity
      end

      def update
        return render json: { errors: ['invalid params'] }, status: :bad_request if user_params.empty?
        return render json: current_user, status: :ok if current_user.update(user_params)

        render json: { errors: ['something went wrong'] }, status: :internal_server_error
      rescue ActiveRecord::RecordNotFound => e
        user_not_found_response(e)
      end

      def destroy
        current_user.destroy!

        render json: current_user, status: :ok
      rescue ActiveRecord::RecordNotFound => e
        user_not_found_response(e)
      end

      private

      def user_params
        params.permit(%i[username password password_confirmation email first_name last_name])
      end

      def user_id
        params.permit(:id)
      end

      def user_validation_errors(user)
        { errors: user.errors.full_messages }
      end
    end
  end
end
