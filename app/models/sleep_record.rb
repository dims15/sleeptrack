class SleepRecord < ApplicationRecord
  belongs_to :user_id, class_name: "User"

  validates :user_id, presence: true

  validate :ensure_one_of_time_present

  private

  def ensure_one_of_time_present
    if !sleep_time.present? || !wake_time.present?
      errors.add(:base, "Either sleep_time or wake_time must be present")
    end
  end
end
