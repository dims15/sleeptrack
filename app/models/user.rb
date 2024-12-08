class User < ApplicationRecord
  has_many :following, class_name: "Follow", foreign_key: "user_id"
  has_many :follower, class_name: "Follow", foreign_key: "following_user_id"
  has_many :sleep_records, class_name: "SleepRecord", foreign_key: "user_id"

  validates :name, presence: true
end
