module Api
  module V1
    class SleepTrackController < ApiController
      def create
        sleep_track = SleepTrack::CreateService.new(sleep_track_params).execute
        render json: { message: "Sleep track record created successfully", sleep_track: sleep_track }, status: :created
      rescue ErrorService => e
        render json: { errors: e.errors }, status: :unprocessable_entity
      end

      def sleep_track_params
        params.require(:sleep_track).permit(:sleep_time, :wake_time, :user_id)
      end
    end
  end
end
