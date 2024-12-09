require "rails_helper"

RSpec.describe SleepTrack::CreateService, type: :service do
  let(:user) { create(:user) }
  let(:sleep_time) { (Time.now - 8.hours).round(6) }
  let(:wake_time) { Time.now.round(6) }
  let(:valid_params) do
    {
      user_id: user.id,
      sleep_time: sleep_time,
      wake_time: wake_time
    }
  end

  describe "#execute" do
    context "when creating a new sleep record" do
      it "creates the sleep record successfully" do
        service = SleepTrack::CreateService.new(valid_params)
        sleep_record = service.execute

        expect(sleep_record).to be_persisted
        expect(sleep_record.user_id).to eq(user.id)
        expect(sleep_record.sleep_time).to eq(sleep_time)
        expect(sleep_record.wake_time).to eq(wake_time)
        expect(sleep_record.duration).to eq(((wake_time - sleep_time) / 60).to_i)
      end
    end

    context "when a similar deleted record exists" do
      let!(:deleted_record) { create(:sleep_record, **valid_params, deleted_at: Time.now) }

      it "reactivates the deleted sleep record" do
        service = SleepTrack::CreateService.new(valid_params)
        sleep_record = service.execute

        expect(sleep_record.id).to eq(deleted_record.id)
        expect(sleep_record.deleted_at).to be_nil
      end
    end

    context "when validation fails" do
      it "raises a ValidationError when user_id is missing" do
        invalid_params = valid_params.except(:user_id)
        service = SleepTrack::CreateService.new(invalid_params)

        expect { service.execute }.to raise_error(ValidationError) do |error|
          expect(error.errors[:user_id]).to include("can't be blank")
        end
      end

      it "raises a ValidationError when sleep_time is missing" do
        invalid_params = valid_params.except(:sleep_time)
        service = SleepTrack::CreateService.new(invalid_params)

        expect { service.execute }.to raise_error(ValidationError) do |error|
          expect(error.errors[:sleep_time]).to include("can't be blank")
        end
      end

      it "raises a ValidationError for duplicate sleep_time and wake_time" do
        create(:sleep_record, **valid_params)
        service = SleepTrack::CreateService.new(valid_params)

        expect { service.execute }.to raise_error(ValidationError) do |error|
          expect(error.errors[:base]).to include("The combination of sleep_time and wake_time must be unique")
        end
      end
    end
  end
end
