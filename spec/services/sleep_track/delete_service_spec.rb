require 'rails_helper'

RSpec.describe SleepTrack::DeleteService, type: :service do
  let(:user) { create(:user) }
  let(:sleep_record) { create(:sleep_record, user: user) }
  let(:delete_service) { described_class.new(id: sleep_record.id) }

  describe "#execute" do
    context "when the record exists and is not deleted" do
      it "marks the record as deleted" do
        expect {
          delete_service.execute
        }.to change { sleep_record.reload.deleted_at }.from(nil).to(be_a(Time))
      end
    end

    context "when the record does not exist" do
      it "raises a NotFoundError" do
        non_existing_id = 9999
        service = described_class.new(id: non_existing_id)
        
        expect { service.execute }.to raise_error(NotFoundError)
      end
    end
  end
end
