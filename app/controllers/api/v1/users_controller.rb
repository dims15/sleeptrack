module Api
  module V1
    class UsersController < ApiController
      def create
        user = Users::CreateService.new(user_create_params).execute
        render json: { message: "User created successfully", user: user }, status: :created
      rescue ErrorService => e
        render json: { errors: e.errors }, status: :unprocessable_entity
      end

      def follow
        follow = Users::FollowService.new(follow_params).execute
        render json: { message: "User followed", follow: follow }, status: :created
      rescue ErrorService => e
        render json: { errors: e.errors }, status: :unprocessable_entity
      end

      def user_create_params
        params.require(:user).permit(:name)
      end

      def follow_params
        params.permit(:user_id, :target_user_id)
      end
    end
  end
end
