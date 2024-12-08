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

      raise ErrorService.new(@errors) if @errors.any?

      if any_record_deleted?
        follow = update_record
      else
        follow = create_record
      end

      unless follow.persisted?
        raise ErrorService.new(follow.errors.messages)
      end

      follow

    rescue ActiveRecord::RecordNotUnique => e
      add_rescue_error(errors, :base, "A record with this value already exists")
    end

    private

    def create_record
      follow = Follow.create(
        user_id: @user_id,
        following_user_id: @target_user_id
      )

      follow
    end

    def update(record)
      @deleted_record.update(deleted_at: nil)

      @deleted_record
    end

    def any_record_deleted?
      @deleted_record = Follow.where(user_id: @user_id, following_user_id: @target_user_id)
      .where.not(deleted_at: nil)
      .take

      @deleted_record.present?
    end

    def validate_params!
      ValidationErrorHelper.add_error(@errors, :user_id, "Can't be blank") if @user_id.blank?
      ValidationErrorHelper.add_error(@errors, :target_user_id, "Can't be blank") if @target_user_id.blank?
    end
  end
end
