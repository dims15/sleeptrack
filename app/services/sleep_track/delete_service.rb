module SleepTrack
  class DeleteService
    include ModelValidationHelper

    def initialize(id:)
      @id = id
    end

    def execute
      record = SleepRecord.find_by!(id: @id, deleted_at: nil)

      record.update(deleted_at: Time.now)

    rescue ActiveRecord::RecordNotFound => e
      raise NotFoundError.new(e)
    end
  end
end
