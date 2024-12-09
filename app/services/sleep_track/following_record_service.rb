module SleepTrack
  class FollowingRecordService
    def initialize(params)
      @params = params || {}
      @errors = {}
    end

    def execute
      check_user_exist
      validate_sort_order
      validate_dates
      set_default_dates

      raise ValidationError.new(@errors) if @errors.any?

      retrieve
    end

    private

    def retrieve
      following_users = @selected_user.following.where(follows: { deleted_at: nil })
      sleep_records = SleepRecord.where(user: following_users.map(&:following_user))
                         .where(deleted_at: nil)
                         .where.not(sleep_records: { duration: nil })
                         .where("DATE(sleep_time) >= ?", @params[:start_date])
                         .where("DATE(sleep_time) <= ?", @params[:end_date])
                         .order(duration: @params[:sort_order])

      sleep_records
    end

    def check_user_exist
      @selected_user = User.find_by!(id: @params[:id], deleted_at: nil)

    rescue ActiveRecord::RecordNotFound => e
      raise NotFoundError.new(e)
    end

    def validate_dates
      begin
        Date.parse(@params[:start_date]) if @params[:start_date].present?
        Date.parse(@params[:end_date]) if @params[:end_date].present?
      rescue ArgumentError
        ValidationErrorHelper.add_error(@errors, :date, "Invalid date format. Expected 'YYYY-MM-DD'.")
      end
    end

    def validate_sort_order
      valid_sort_orders = %w[asc desc]
      @params[:sort_order] = "desc" unless valid_sort_orders.include?(@params[:sort_order])
    end

    def set_default_dates
      unless @params[:start_date].present? && @params[:end_date].present?
        last_week = (Date.today.beginning_of_week(:sunday) - 1.week)..(Date.today.beginning_of_week(:sunday) - 1.day)

        @params[:start_date] ||= last_week.begin
        @params[:end_date] ||= last_week.end
      end
    end
  end
end
