require "rails_helper"

RSpec.describe SleepTrack::UpdateService, type: :service do
  let(:user) { create(:user) }
  let(:sleep_record) { create(:sleep_record, user: user) }
  let(:valid_params) do
    {
      sleep_time: (Time.now - 6.hours).utc.iso8601,
      wake_time: (Time.now - 3.hours).utc.iso8601
    }
  end
  let(:invalid_params) do
    {
      sleep_time: nil,
      wake_time: nil
    }
  end

  describe "#execute" do
    context "when the record exists and parameters are valid" do
      it "updates the sleep record successfully" do
        service = SleepTrack::UpdateService.new(sleep_record.id, valid_params)

        result = service.execute

        expect(result).to be_a(SleepRecord)
        expect(result.sleep_time).to eq(Time.iso8601(valid_params[:sleep_time]))
        expect(result.wake_time).to eq(Time.iso8601(valid_params[:wake_time]))
        expect(result.errors).to be_empty
      end
    end

    context "when the record does not exist" do
      it "raises a ValidationError with a record not found message" do
        service = SleepTrack::UpdateService.new(9999, valid_params)

        expect { service.execute }.to raise_error(NotFoundError)
      end
    end

    context "when the record exists but parameters are invalid" do
      it "raises a ValidationError with errors on invalid attributes" do
        service = SleepTrack::UpdateService.new(sleep_record.id, invalid_params)

        expect { service.execute }.to raise_error(ValidationError) do |error|
          expect(error.errors[:sleep_time]).to include("can't be blank")
        end
      end
    end
  end
end
