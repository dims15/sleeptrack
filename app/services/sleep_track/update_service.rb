module SleepTrack
  class UpdateService
    include ErrorHandlingHelper
    include ModelValidationHelper

    def initialize(id, params)
      @id = id
      @params = params
      @errors = {}
    end

    def execute
      check_record_exist

      @sleep_record.assign_attributes(@params)

      validate_model(@sleep_record)

      raise ValidationError.new(@errors) if @errors.any?

      @sleep_record.update(@params)

      @sleep_record
    end

    private

    def check_record_exist
      @sleep_record = SleepRecord.find_by!(id: @id, deleted_at: nil)

    rescue ActiveRecord::RecordNotFound => e
      raise NotFoundError.new(e)
    end
  end
end
