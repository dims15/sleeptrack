module Api
  module V1
    class SleepTrackController < ApiController
      def create
        sleep_track = SleepTrack::CreateService.new(sleep_track_params).execute
        render json: { message: "Sleep track record created successfully", sleep_track: sleep_track }, status: :created
      end

      def update
        sleep_track = SleepTrack::UpdateService.new(params[:id], update_sleep_track_params).execute
        render json: { message: "Sleep track record updated successfully", sleep_track: sleep_track }, status: :ok
      end

      def delete
        SleepTrack::DeleteService.new(id: params[:id]).execute
        render json: { message: "Sleep track record deleted successfully" }, status: :ok
      end

      def index
        selected_user = User.find_by_id(params[:id])
        following_users = selected_user.following.where(follows: { deleted_at: nil })
        sleep_records = SleepRecord.where(user: following_users.map(&:following_user))
                           .where(deleted_at: nil)
                           .where.not(sleep_records: { duration: nil })
                           .where("DATE(sleep_time) >= ?", params[:start_date])
                           .where("DATE(sleep_time) <= ?", params[:end_date])
                           .order(duration: params[:sort])

        render json: sleep_records, each_serializer: SleepRecordSerializer
      end

      private

      def sleep_track_params
        params.require(:sleep_track).permit(:sleep_time, :wake_time, :user_id)
      end

      def update_sleep_track_params
        params.require(:sleep_track).permit(:sleep_time, :wake_time)
      end
    end
  end
end
