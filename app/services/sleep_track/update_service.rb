module SleepTrack
  class UpdateService
    include ErrorHandlingHelper

    def initialize(id, params)
      @id = id
      @params = params
      @errors = {}
    end

    def execute
      check_record_exist

      @sleep_record.assign_attributes(@params)

      update

      if @errors.any?
        raise ValidationError.new(@errors)
      end

      @sleep_record
    end

    private

    def check_record_exist
      @sleep_record = SleepRecord.find_by!(id: @id, deleted_at: nil)

    rescue ActiveRecord::RecordNotFound => e
      add_rescue_error(@errors, "Record not found.")
      raise ValidationError.new(@errors)
    end

    def update
      if @sleep_record.valid?
        @sleep_record.update(@params)
      else
        @sleep_record.errors.each do |field, message|
          ValidationErrorHelper.add_error(@errors, field.attribute, field.type)
        end
      end
    end
  end
end
