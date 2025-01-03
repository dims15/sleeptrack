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
        sleep_records = SleepTrack::FollowingRecordService.new(params).execute

        # render json: sleep_records, each_serializer: SleepRecordSerializer

        @pagy, @sleep_records = pagy(sleep_records)

        render json: {
          sleep_records: @sleep_records,
          meta: pagination_metadata(@pagy)
        }, each_serializer: ClockInSerializer
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
