require 'rails_helper'

RSpec.describe Api::V1::SleepTrackController, type: :request do
  let(:user) { create(:user) }
  let(:sleep_record) { create(:sleep_record, user: user) }

  let(:valid_params) do
    {
      sleep_track: {
        sleep_time: (Time.now - 6.hours).utc.iso8601,
        wake_time: (Time.now - 3.hours).utc.iso8601
      }
    }
  end

  let(:invalid_params) do
    {
      sleep_track: {
        sleep_time: nil,
        wake_time: nil
      }
    }
  end

  describe "PATCH /api/v1/sleep-track/:id" do
    context "when the record exists and parameters are valid" do
      it "updates the sleep track record and returns 200 status" do
        patch "/api/v1/sleep-track/#{sleep_record.id}", params: valid_params
        
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body, symbolize_names: true)
        expect(json_response[:message]).to eq("Sleep track record updated successfully")
        
        updated_record = SleepRecord.find(sleep_record.id)
        expect(updated_record.sleep_time).to eq(Time.iso8601(valid_params[:sleep_track][:sleep_time]))
        expect(updated_record.wake_time).to eq(Time.iso8601(valid_params[:sleep_track][:wake_time]))
      end
    end

    context "when the record does not exist" do
      it "returns a 404 status with an error message" do
        patch "/api/v1/sleep-track/9999", params: valid_params
        
        expect(response).to have_http_status(:not_found)
        json_response = JSON.parse(response.body, symbolize_names: true)
        expect(json_response[:message]).to include("Record not found")
      end
    end

    context "when the parameters are invalid" do
      it "returns a 422 status with an error message" do
        patch "/api/v1/sleep-track/#{sleep_record.id}", params: invalid_params
        
        expect(response.status).to eq(422)
        json_response = JSON.parse(response.body, symbolize_names: true)
        expect(json_response[:message]).to include("Validation failed")
      end
    end
  end
end
