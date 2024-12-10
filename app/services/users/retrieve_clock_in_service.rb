module Users
  class RetrieveClockInService
    def initialize(params)
      @params = params
    end

    def execute
      validate_user
      validate_sort_order

      @user.sleep_records.where(deleted_at: nil).order(created_at: @params[:sort_order])
    end

    private

    def validate_user
      @user = User.find_by!(id: @params[:id])

    rescue ActiveRecord::RecordNotFound => e
      raise NotFoundError.new(e)
    end

    def validate_sort_order
      valid_sort_orders = %w[asc desc]
      @params[:sort_order] = "desc" unless valid_sort_orders.include?(@params[:sort_order])
    end
  end
end
