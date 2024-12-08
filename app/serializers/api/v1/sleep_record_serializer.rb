module Api
  module V1
class SleepRecordSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :name, :sleep_time, :wake_time, :duration

  def name
    object.user.name
  end
end
end
end
