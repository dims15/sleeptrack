module SleepTrack
  class CreateService
    include ErrorHandlingHelper
    include ModelValidationHelper

    def initialize(params)
      @params = params
      @errors = {}
    end

    def execute
      if any_record_deleted?
        return update_record
      end

      @sleep_record = SleepRecord.new(@params)

      validate_model(@sleep_record)

      raise ValidationError.new(@errors) if @errors.any?

      @sleep_record.save!
      @sleep_record
    end

    private

    def any_record_deleted?
      @deleted_record = SleepRecord.where(
        user_id: @params[:user_id],
        sleep_time: @params[:sleep_time],
        wake_time: @params[:wake_time])
      .where.not(deleted_at: nil)
      .take
      @deleted_record.present?
    end

    def update_record
      @deleted_record.update(deleted_at: nil)

      @deleted_record
    end
  end
end
