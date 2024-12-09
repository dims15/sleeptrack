require 'rails_helper'

RSpec.describe SleepRecord, type: :model do
  describe "associations" do
    it "belongs to a user" do
      sleep_record = build(:sleep_record)
      expect(sleep_record.user).to be_instance_of(User)
    end
  end

  describe "validations" do
    it "is valid with valid attributes" do
      user = create(:user)
      sleep_record = build(:sleep_record, user: user)
      expect(sleep_record).to be_valid
    end

    it "is not valid without a user_id" do
      sleep_record = build(:sleep_record, user_id: nil)
      expect(sleep_record).to_not be_valid
      expect(sleep_record.errors[:user_id]).to include("can't be blank")
    end

    it "is not valid without a sleep_time" do
      sleep_record = build(:sleep_record, sleep_time: nil)
      expect(sleep_record).to_not be_valid
      expect(sleep_record.errors[:sleep_time]).to include("can't be blank")
    end

    it "is not valid if the combination of sleep_time and wake_time is not unique" do
      user = create(:user)
      dummy_time = Time.now
      create(:sleep_record, user: user, sleep_time: dummy_time - 8.hours, wake_time: dummy_time)

      sleep_record = build(:sleep_record, user: user, sleep_time: dummy_time - 8.hours, wake_time: dummy_time)
      expect(sleep_record).to_not be_valid
      expect(sleep_record.errors[:base]).to include("The combination of sleep_time and wake_time must be unique")
    end
  end

  describe "callbacks" do
    it "calculates the duration before save" do
      user = create(:user)
      sleep_record = build(:sleep_record, user: user, sleep_time: Time.now - 8.hours, wake_time: Time.now)
      expect(sleep_record.duration).to be_nil

      sleep_record.save
      expect(sleep_record.duration).to eq(480)
    end
  end
end
