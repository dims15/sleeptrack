module Users
  class FollowService
    include ModelValidationHelper

    def initialize(params)
      @params = params
      @user_id = params[:user_id]
      @target_user_id = params[:following_user_id]
      @errors = {}
    end

    def execute
      validate_params

      raise ValidationError.new(@errors) if @errors.any?

      if any_record_deleted?
        return update_record
      end

      @follow.save!
      @follow

    rescue ActiveRecord::RecordNotUnique => e
      ValidationErrorHelper.add_error(@errors, :base, "User already following this account")
      raise ValidationError.new(@errors)
    end

    private

    def create_record
      follow = Follow.create(
        user_id: @user_id,
        following_user_id: @target_user_id
      )

      follow
    end

    def update_record
      @deleted_record.update(deleted_at: nil)

      @deleted_record
    end

    def any_record_deleted?
      @deleted_record = Follow.where(user_id: @user_id, following_user_id: @target_user_id)
      .where.not(deleted_at: nil)
      .take

      @deleted_record.present?
    end

    def validate_params
      @follow = Follow.new(@params)

      validate_model(@follow)
    end
  end
end
