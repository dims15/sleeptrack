module Users
  class UnfollowService
    include ErrorHandlingHelper

    def initialize(params)
      @user_id = params[:user_id]
      @target_user_id = params[:target_user_id]
      @errors = {}
    end

    def execute
      validate_params!
      check_user_follow_exist

      raise ErrorService.new(@errors) if @errors.any?

      unless @following_record.update(deleted_at: Time.current)
        raise ErrorService.new(unfollow.errors.messages)
      end

      @following_record
    end

    private

    def check_user_follow_exist
      @following_record = Follow.find_by!(
        user_id: @user_id,
        following_user_id: @target_user_id,
        deleted_at: nil)

    rescue ActiveRecord::RecordNotFound => e
      add_rescue_error(@errors, "User id #{@user_id} is not follow user id #{@target_user_id}.")
    end

    def validate_params!
      ValidationErrorHelper.add_error(@errors, :user_id, "Can't be blank") if @user_id.blank?
      ValidationErrorHelper.add_error(@errors, :target_user_id, "Can't be blank") if @target_user_id.blank?
    end
  end
end
