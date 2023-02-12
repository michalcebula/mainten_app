# frozen_string_literal: true

module Api
  module V1
    class UsersController < Api::V1::BaseController
      skip_before_action :authenticate_request, only: [:create]

      def index
        users = User.all
        render_response(body: users, serializer: UserSerializer, paginated: true)
      end

      def show
        @user = set_user
        return render_unauthorized if @user != current_user

        render_response(body: current_user, serializer: UserSerializer)
      rescue ActiveRecord::RecordNotFound => e
        user_not_found_response(e)
      end

      def create
        user = User.new(user_params)
        return render_response(status: :created, body: create_user_body(user)) if user.save

        render json: user_validation_errors(user), status: :unprocessable_entity
      end

      def update
        return render_invalid_params if user_params.empty?

        current_user.assign_attributes(user_params)
        return render_response(body: current_user, serializer: UserSerializer) if current_user.save

        render_general_error
      rescue ActiveRecord::RecordNotFound => e
        user_not_found_response(e)
      end

      def destroy
        @user = set_user
        return render_unauthorized if @user != current_user

        @user.destroy!

        render_response(body: current_user, serializer: UserSerializer)
      rescue ActiveRecord::RecordNotFound => e
        user_not_found_response(e)
      end

      private

      def set_user
        @user = User.find(user_id[:id])
      end

      def user_params
        params.permit(%i[username password password_confirmation email first_name last_name])
      end

      def user_id
        params.permit(:id)
      end

      def user_validation_errors(user)
        { errors: user.errors.full_messages }
      end
      
      def create_user_body(user)
        token = jwt_auth.encode(user_id: user.id)
        UserSerializer.new(user).serializable_hash.merge(jwt: token)
      end
    end
  end
end
