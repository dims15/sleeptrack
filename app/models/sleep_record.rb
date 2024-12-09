class SleepRecord < ApplicationRecord
  belongs_to :user, class_name: "User"

  include DatetimeValidator

  validates :user_id, presence: true
  validates :sleep_time, presence: true

  validate :unique_sleep_and_wake_times

  before_save :calculate_duration

  private

  def calculate_duration
    if sleep_time.present? && wake_time.present?
      self.duration = ((wake_time - sleep_time) / 60).to_i
    end
  end

  def datetime_fields
    [ :sleep_time, :wake_time ]
  end

  def datetime_field_pairs
    { sleep_time: :wake_time }
  end

  def unique_sleep_and_wake_times
    existing_record = SleepRecord.where(
      sleep_time: sleep_time,
      wake_time: wake_time,
      user_id: user_id)
      .where.not(id: id).exists?
    if existing_record
      errors.add(:base, "The combination of sleep_time and wake_time must be unique")
    end
  end
end
