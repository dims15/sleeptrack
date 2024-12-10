require 'rails_helper'

RSpec.describe SleepTrack::FollowingRecordService, type: :service do
  let(:user) { create(:user) }
  let(:following_user) { create(:user) }
  let!(:follow) { create(:follow, user: user, following_user: following_user) }
  let!(:sleep_record1) { create(:sleep_record, user: following_user, sleep_time: 1.day.ago, wake_time: Time.current) }
  let!(:sleep_record2) { create(:sleep_record, user: following_user, sleep_time: 2.days.ago + 1.hours, wake_time: 1.day.ago) }

  let(:params) do
    {
      id: user.id,
      start_date: (Date.today - 7).to_s,
      end_date: Date.today.to_s,
      sort_order: 'asc'
    }
  end

  subject { described_class.new(params) }

  describe "#execute" do
    context "with valid parameters" do
      it "retrieves the sleep records of following users" do
        result = subject.execute

        expect(result).to match_array([ sleep_record2, sleep_record1 ])
        expect(result.first.duration).to be_present
      end

      it "returns records sorted by duration in ascending order" do
        params[:sort_order] = 'asc'

        result = subject.execute
        expect(result).to match_array([ sleep_record2, sleep_record1 ])
        expect(result.map(&:id)).to eq([ sleep_record2.id, sleep_record1.id ])
      end

      it "returns records sorted by duration in descending order by default" do
        params[:sort_order] = nil

        result = subject.execute

        expect(result).to eq([ sleep_record1, sleep_record2 ])
      end
    end

    context "when user does not exist" do
      it "raises a NotFoundError" do
        params[:id] = 9999

        expect { subject.execute }.to raise_error(NotFoundError)
      end
    end

    context "when date format is invalid" do
      it "raises a ValidationError with appropriate message" do
        params[:start_date] = "invalid-date"

        expect { subject.execute }.to raise_error(ValidationError) do |error|
          expect(error.errors[:date]).to eq([ "Invalid date format. Expected 'YYYY-MM-DD'." ])
        end
      end
    end

    context "when dates are missing" do
      it "sets default dates to the last week's range" do
        params.delete(:start_date)
        params.delete(:end_date)

        result = subject.execute

        expect(result).to eq([])
      end
    end

    context "when following users have no valid sleep records" do
      it "returns an empty array" do
        sleep_record1.update(deleted_at: Time.current)
        sleep_record2.update(deleted_at: Time.current)

        result = subject.execute

        expect(result).to be_empty
      end
    end
  end
end
