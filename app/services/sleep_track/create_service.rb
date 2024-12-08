module SleepTrack
  class CreateService
    include ErrorHandlingHelper

    def initialize(params)
      @params = params.slice(:sleep_time, :wake_time, :user_id)
      @errors = {}
    end

    def execute
      @sleep_record = SleepRecord.new(@params)

      validate_model

      if @errors.any?
        raise ErrorService.new(@errors)
      end

      @sleep_record.save!
      @sleep_record
    end

    private

    def validate_model
      unless @sleep_record.valid?
        @sleep_record.errors.each do |field, message|
          ValidationErrorHelper.add_error(@errors, field.attribute, field.type)
        end
      end
    end
  end
end
