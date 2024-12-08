class Follow < ApplicationRecord
  belongs_to :user, class_name: "User"
  belongs_to :following_user, class_name: "User"

  validate :ensure_both_account_present, :ensure_both_not_the_same_id

  private

  def ensure_both_account_present
    if !user_id.present? || !following_user_id.present?
      errors.add(:base, "Invalid user follow")
    end
  end

  def ensure_both_not_the_same_id
    if user_id.present? && following_user_id.present?
      if user_id == following_user_id
        errors.add(:base, "Cannot follow or unfollow yourself")
      end
    end
  end
end
