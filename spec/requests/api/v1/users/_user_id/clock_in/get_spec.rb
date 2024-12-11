require 'rails_helper'

RSpec.describe "Api::V1::Users", type: :request do
  let(:user) { create(:user) }
  let!(:sleep_record1) { create(:sleep_record, user: user, created_at: 2.days.ago) }
  let!(:sleep_record2) { create(:sleep_record, user: user, created_at: 1.day.ago) }
  let!(:deleted_sleep_record) { create(:sleep_record, user: user, created_at: 3.days.ago, deleted_at: Time.current) }

  let(:headers) { { "Content-Type" => "application/json" } }

  describe "GET /api/v1/users/:user_id/clock_in" do
    context "when the user exists" do
      it "returns clock-in records in descending order by default" do
        get "/api/v1/users/#{user.id}/clock_in", headers: headers

        expect(response).to have_http_status(:ok)
        expect(json_body['clock_in_records'].size).to eq(2)
        expect(json_body['clock_in_records'][0]["id"]).to eq(sleep_record2.id)
        expect(json_body['clock_in_records'][1]["id"]).to eq(sleep_record1.id)
      end

      it "returns clock-in records in ascending order when specified" do
        get "/api/v1/users/#{user.id}/clock_in", params: { sort_order: "asc" }, headers: headers

        expect(response).to have_http_status(:ok)
        expect(json_body['clock_in_records'].size).to eq(2)
        expect(json_body['clock_in_records'][0]["id"]).to eq(sleep_record1.id)
        expect(json_body['clock_in_records'][1]["id"]).to eq(sleep_record2.id)
      end

      it "does not include deleted records" do
        get "/api/v1/users/#{user.id}/clock_in", headers: headers

        record_ids = json_body['clock_in_records'].map { |record| record["id"] }
        expect(record_ids).not_to include(deleted_sleep_record.id)
      end

      it "contains pagination meta" do
        get "/api/v1/users/#{user.id}/clock_in", headers: headers

        expect(json_body["meta"]).to include(
          "current_page" => 1,
          "next_page" => nil,
          "prev_page" => nil,
          "total_pages" => 1,
          "total_count" => 2
        )
      end
    end

    context "when the user does not exist" do
      it "returns a 404 status with an error message" do
        get "/api/v1/users/9999/clock_in", headers: headers

        expect(response).to have_http_status(:not_found)
        expect(json_body["message"]).to eq("Record not found")
      end
    end

    context "when the sort order is invalid" do
      it "defaults to descending order" do
        get "/api/v1/users/#{user.id}/clock_in", params: { sort_order: "invalid" }, headers: headers

        expect(response).to have_http_status(:ok)
        expect(json_body['clock_in_records'].size).to eq(2)
        expect(json_body['clock_in_records'][0]["id"]).to eq(sleep_record2.id)
        expect(json_body['clock_in_records'][1]["id"]).to eq(sleep_record1.id)
      end
    end

    context "when the user has no clock-in records" do
      let(:other_user) { create(:user) }

      it "returns an empty array" do
        get "/api/v1/users/#{other_user.id}/clock_in", headers: headers

        expect(response).to have_http_status(:ok)
        expect(json_body['clock_in_records']).to be_empty
      end
    end
  end

  def json_body
    JSON.parse(response.body)
  end
end
