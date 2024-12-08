module Users
  class FollowService
  include ErrorHandlingHelper

    def initialize(params)
      @user_id = params[:user_id]
      @target_user_id = params[:target_user_id]
      @errors = {}
    end

    def execute
      validate_params!

      follow = Follow.create(
        user_id: @user_id,
        following_user_id: @target_user_id
      )

      unless follow.persisted?
        raise ErrorService.new(follow.errors.messages)
      end

      follow

    rescue ActiveRecord::RecordNotUnique => e
      add_unique_error(@errors, follow, e)
    end

    private

    def validate_params!
      ValidationErrorHelper.add_error(@errors, :user_id, "Can't be blank") if @user_id.blank?
      ValidationErrorHelper.add_error(@errors, :target_user_id, "Can't be blank") if @target_user_id.blank?

      raise ErrorService.new(@errors) if @errors.any?
    end
  end
end
