module Api
  module V1
    class UsersController < ApiController
      def create
        user = Users::CreateService.new(user_create_params).execute
        render json: { message: "User created successfully", user: user }, status: :created
      end

      def follow
        follow = Users::FollowService.new(follow_unfollow_params).execute
        render json: { message: "User followed", follow: follow }, status: :ok
      end

      def unfollow
        unfollow = Users::UnfollowService.new(follow_unfollow_params).execute
        render json: { message: "User unfollowed", unfollow: unfollow }, status: :ok
      end

      def retrieve_clock_in
        clock_in_records = Users::RetrieveClockInService.new(params).execute
        render json: clock_in_records, each_serializer: ClockInSerializer
      end

      private

      def user_create_params
        params.require(:user).permit(:name)
      end

      def follow_unfollow_params
        params.permit(:user_id, :following_user_id)
      end
    end
  end
end
