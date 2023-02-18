# frozen_string_literal: true

module Api
  module V1
    class UsersController < Api::V1::BaseController
      def index
        return render_unauthorized unless Api::UserPolicy.index?(current_user)

        render_response(body: User.all, serializer: UserSerializer, paginated: true)
      end

      def show
        @user = set_user
        return render_unauthorized unless Api::UserPolicy.show?(current_user, @user.id)

        render_response(body: @user, serializer: UserSerializer)
      rescue ActiveRecord::RecordNotFound => e
        user_not_found_response(e)
      end

      def create
        return render_unauthorized unless Api::UserPolicy.create?(current_user)

        user = User.new(user_params)
        return render_response(status: :created, body: create_user_body(user)) if UserRepository.save(user)

        render json: user_validation_errors(user), status: :unprocessable_entity
      end

      def update
        user = set_user
        return render_unauthorized unless Api::UserPolicy.update?(current_user, user.id)
        return render_invalid_params if user_params.empty?

        user.assign_attributes(user_params)
        return render_response(body: user, serializer: UserSerializer) if UserRepository.save(user)

        render json: user_validation_errors(user), status: :unprocessable_entity
      rescue ActiveRecord::RecordNotFound => e
        user_not_found_response(e)
      end

      def destroy
        user = set_user
        return render_unauthorized unless Api::UserPolicy.destroy?(current_user, user.id)

        render_response(body: user, serializer: UserSerializer) if user.destroy!
      rescue ActiveRecord::RecordNotFound => e
        user_not_found_response(e)
      end

      private

      def set_user
        return current_user if current_user.id == user_id

        UserRepository.find(user_id)
      end

      def user_params
        params.permit(%i[username password password_confirmation email first_name last_name])
      end

      def user_id
        params.permit(:id)[:id]
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
