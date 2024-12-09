require 'rails_helper'

RSpec.describe Follow, type: :model do
  describe "associations" do
    it "belongs to a user (follower)" do
      follow = build(:follow)
      expect(follow.user).to be_instance_of(User)
    end

    it "belongs to a following_user (followed)" do
      follow = build(:follow)
      expect(follow.following_user).to be_instance_of(User)
    end
  end

  describe "validations" do
    it "is valid with valid attributes" do
      user1 = create(:user)
      user2 = create(:user)
      follow = build(:follow, user: user1, following_user: user2)
      expect(follow).to be_valid
    end

    it "is not valid without a user (follower)" do
      follow = build(:follow, user: nil)
      expect(follow).to_not be_valid
    end

    it "is not valid without a following_user (followed)" do
      follow = build(:follow, following_user: nil)
      expect(follow).to_not be_valid
    end

    it "is not valid if the user is following themselves" do
      user = create(:user)
      follow = build(:follow, user: user, following_user: user)
      expect(follow).to_not be_valid
      expect(follow.errors[:base]).to include("Cannot follow or unfollow yourself")
    end

    it "is not valid if user_id and following_user_id is missing" do
      follow = build(:follow, user_id: nil, following_user_id: nil)
      expect(follow).to_not be_valid
      expect(follow.errors[:base]).to include("Invalid user follow")
    end
  end
end
