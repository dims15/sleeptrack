class Follow < ApplicationRecord
  belongs_to :user_id, class_name: 'User'
  belongs_to :following_user_id, class_name: 'User'

  validate :ensure_both_account_present

  private

  def ensure_both_account_present
    if !user_id.present? || !following_user_id.present?
      errors.add(:base, "Invalid user follow")
    end
  end
end