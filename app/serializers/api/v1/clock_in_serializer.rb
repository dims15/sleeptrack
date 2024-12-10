module Api
  module V1
    class ClockInSerializer < ActiveModel::Serializer
      attributes :id, :name, :clock_in_time, :created_at

      def name
        object.user.name
      end

      def clock_in_time
        object.sleep_time
      end
    end
  end
end
