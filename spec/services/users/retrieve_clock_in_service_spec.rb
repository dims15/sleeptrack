require 'rails_helper'

RSpec.describe Users::RetrieveClockInService, type: :service do
  let(:user) { create(:user) }
  let!(:sleep_record1) { create(:sleep_record, user: user, created_at: 2.days.ago) }
  let!(:sleep_record2) { create(:sleep_record, user: user, created_at: 1.day.ago) }
  let!(:deleted_sleep_record) { create(:sleep_record, user: user, created_at: 3.days.ago, deleted_at: Time.current) }

  describe "#execute" do
    context "when valid parameters are provided" do
      let(:params) { { user_id: user.id, sort_order: "asc" } }
      let(:service) { described_class.new(params) }

      it "returns the user's sleep records in ascending order" do
        result = service.execute

        expect(result).to eq([ sleep_record1, sleep_record2 ])
        expect(result).not_to include(deleted_sleep_record)
      end
    end

    context "when the user does not exist" do
      let(:params) { { user_id: 9999, sort_order: "asc" } }
      let(:service) { described_class.new(params) }

      it "raises a NotFoundError" do
        expect { service.execute }.to raise_error(NotFoundError)
      end
    end

    context "when an invalid sort order is provided" do
      let(:params) { { user_id: user.id, sort_order: "invalid" } }
      let(:service) { described_class.new(params) }

      it "defaults to descending order" do
        result = service.execute

        expect(result).to eq([ sleep_record2, sleep_record1 ])
      end
    end

    context "when no sort order is provided" do
      let(:params) { { user_id: user.id } }
      let(:service) { described_class.new(params) }

      it "defaults to descending order" do
        result = service.execute

        expect(result).to eq([ sleep_record2, sleep_record1 ])
      end
    end

    context "when the user has no sleep records" do
      let(:other_user) { create(:user) }
      let(:params) { { user_id: other_user.id, sort_order: "asc" } }
      let(:service) { described_class.new(params) }

      it "returns an empty ActiveRecord relation" do
        result = service.execute

        expect(result).to be_empty
      end
    end
  end
end
