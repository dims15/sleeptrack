module Users
  class UnfollowService
    include ModelValidationHelper

    def initialize(params)
      @params = params
      @user_id = params[:user_id]
      @target_user_id = params[:following_user_id]
      @errors = {}
    end

    def execute
      validate_params

      check_user_follow_exist

      raise ValidationError.new(@errors) if @errors.any?

      unless @following_record.update(deleted_at: Time.current)
        raise ValidationError.new(@following_record.errors.messages)
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
      ValidationErrorHelper.add_error(@errors, :base, "User id #{@user_id} is not follow user id #{@target_user_id}.")
      raise ValidationError.new(@errors)
    end

    def validate_params
      @follow = Follow.new(@params)

      validate_model(@follow)

      raise ValidationError.new(@errors) if @errors.any?
    end
  end
end
