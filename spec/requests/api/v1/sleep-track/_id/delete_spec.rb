require 'rails_helper'

RSpec.describe Api::V1::SleepTrackController, type: :request do
  let(:user) { create(:user) }
  let(:sleep_record) { create(:sleep_record, user: user) }

  describe "DELETE /api/v1/sleep-track/:id" do
    context "when the record exists and is not deleted" do
      it "deletes the sleep track record and returns a success message" do
        delete "/api/v1/sleep-track/#{sleep_record.id}"

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body, symbolize_names: true)
        expect(json_response[:message]).to eq("Sleep track record deleted successfully")

        expect(sleep_record.reload.deleted_at).not_to be_nil
      end
    end

    context "when the record does not exist" do
      it "returns a not found error" do
        delete "/api/v1/sleep-track/9999"

        expect(response).to have_http_status(:not_found)
        json_response = JSON.parse(response.body, symbolize_names: true)
        expect(json_response[:message]).to include("Record not found")
      end
    end

    context "when the record is already deleted" do
      it "does not change the deleted_at field" do
        sleep_record.update(deleted_at: Time.now)

        delete "/api/v1/sleep-track/#{sleep_record.id}"

        expect(response).to have_http_status(:not_found)
        json_response = JSON.parse(response.body, symbolize_names: true)
        expect(json_response[:message]).to include("Record not found")
      end
    end
  end
end
