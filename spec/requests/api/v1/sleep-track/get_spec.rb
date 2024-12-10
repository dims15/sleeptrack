require 'rails_helper'

RSpec.describe Api::V1::SleepTrackController, type: :request do
  let(:user) { create(:user) }
  let(:following_user) { create(:user) }
  let!(:follow) { create(:follow, user: user, following_user: following_user) }
  let!(:sleep_record1) { create(:sleep_record, user: following_user, sleep_time: 2.days.ago, wake_time: 1.day.ago) }
  let!(:sleep_record2) { create(:sleep_record, user: following_user, sleep_time: 1.day.ago, wake_time: Time.current) }

  describe "GET /api/v1/sleep-track" do
    let(:valid_params) do
      {
        id: user.id,
        start_date: (Date.today - 7).to_s,
        end_date: Date.today.to_s,
        sort_order: 'asc'
      }
    end

    context "when the request is valid" do
      before { get "/api/v1/sleep-track", params: valid_params }

      it "returns the sleep records of following users" do
        expect(response).to have_http_status(:ok)

        json = JSON.parse(response.body)
        expect(json).to be_an(Array)
        expect(json.size).to eq(2)
        expect(json.first["id"]).to eq(sleep_record1.id)
        expect(json.last["id"]).to eq(sleep_record2.id)
      end
    end

    context "when the user does not exist" do
      before { get "/api/v1/sleep-track", params: valid_params.merge(id: 9999) }

      it "returns a 404 Not Found status" do
        expect(response).to have_http_status(:not_found)

        json = JSON.parse(response.body)
        expect(json["message"]).to eq("Record not found")
      end
    end

    context "when the date format is invalid" do
      before { get "/api/v1/sleep-track", params: valid_params.merge(start_date: "invalid-date") }

      it "returns a 422 Unprocessable Entity status" do
        expect(response.status).to eq(422)

        json = JSON.parse(response.body)
        expect(json['errors']['date']).to include("Invalid date format. Expected 'YYYY-MM-DD'.")
      end
    end

    context "when no sleep records are found" do
      before do
        sleep_record1.update(deleted_at: Time.current)
        sleep_record2.update(deleted_at: Time.current)
        get "/api/v1/sleep-track", params: valid_params
      end

      it "returns an empty array" do
        expect(response).to have_http_status(:ok)

        json = JSON.parse(response.body)
        expect(json).to be_an(Array)
        expect(json).to be_empty
      end
    end
  end
end
