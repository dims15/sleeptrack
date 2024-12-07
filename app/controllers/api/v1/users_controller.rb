module Api
  module V1
    class UsersController < ApiController
      def create
        user = Users::CreateService.new(params).execute
        render json: { message: 'User created successfully', user: user }, status: :created
      rescue ErrorService => e
        render json: { errors: e.errors }, status: :unprocessable_entity
      end
      
      def user_params
        params.require(:user).permit(:name)
      end
    end
  end
end