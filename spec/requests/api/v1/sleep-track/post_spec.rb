require 'rails_helper'

RSpec.describe "Api::V1::SleepTrack", type: :request do
  describe "POST /api/v1/sleep-track" do
    let(:user) { create(:user) }
    let(:valid_params) do
      {
        sleep_track: {
          user_id: user.id,
          sleep_time: ((Time.now - 8.hours).round(6)).utc.iso8601,
          wake_time: (Time.now.round(6)).utc.iso8601
        }
      }
    end

    context "with valid parameters" do
      it "creates a new sleep track record and returns 201 status" do
        post "/api/v1/sleep-track", params: valid_params
    
        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body, symbolize_names: true)
        expect(json_response[:message]).to eq("Sleep track record created successfully")
        expect(json_response[:sleep_track][:user_id]).to eq(user.id)
        
        sleep_time_response = Time.iso8601(json_response[:sleep_track][:sleep_time])
        wake_time_response = Time.iso8601(json_response[:sleep_track][:wake_time])

        sleep_time_expected = Time.iso8601(valid_params[:sleep_track][:sleep_time])
        wake_time_expected = Time.iso8601(valid_params[:sleep_track][:wake_time])

        expect(sleep_time_response).to eq(sleep_time_expected)
        expect(wake_time_response).to eq(wake_time_expected)
      end
    end

    context "with missing parameters" do
      it "returns an error when user_id is missing" do
        invalid_params = valid_params.deep_dup
        invalid_params[:sleep_track].delete(:user_id)

        post "/api/v1/sleep-track", params: invalid_params

        expect(response.status).to eq(422)
        json_response = JSON.parse(response.body, symbolize_names: true)
        expect(json_response[:errors][:user_id]).to include("can't be blank")
      end

      it "returns an error when sleep_time is missing" do
        invalid_params = valid_params.deep_dup
        invalid_params[:sleep_track].delete(:sleep_time)

        post "/api/v1/sleep-track", params: invalid_params

        expect(response.status).to eq(422)
        json_response = JSON.parse(response.body, symbolize_names: true)
        expect(json_response[:errors][:sleep_time]).to include("can't be blank")
      end

      context "with wake_time is missing" do
        it "creates a new sleep track record and returns 201 status" do
          invalid_params = valid_params.deep_dup
          invalid_params[:sleep_track].delete(:wake_time)
  
          post "/api/v1/sleep-track", params: invalid_params
  
          expect(response).to have_http_status(:created)
          json_response = JSON.parse(response.body, symbolize_names: true)
          expect(json_response[:message]).to eq("Sleep track record created successfully")
          expect(json_response[:sleep_track][:user_id]).to eq(user.id)
          
          sleep_time_response = Time.iso8601(json_response[:sleep_track][:sleep_time])

          sleep_time_expected = Time.iso8601(valid_params[:sleep_track][:sleep_time])

          expect(sleep_time_response).to eq(sleep_time_expected)
          expect(json_response[:sleep_track][:wake_time]).to eq nil
        end
      end
    end

    context "with a duplicate sleep track record" do
      it "returns an error when a record with the same sleep_time and wake_time exists" do
        create(:sleep_record, user_id: user.id, sleep_time: valid_params[:sleep_track][:sleep_time], wake_time: valid_params[:sleep_track][:wake_time])

        post "/api/v1/sleep-track", params: valid_params

        expect(response.status).to eq(422)
        json_response = JSON.parse(response.body, symbolize_names: true)
        expect(json_response[:errors][:base]).to include("The combination of sleep_time and wake_time must be unique")
      end
    end

    context "when reactivating a deleted record" do
      let!(:deleted_record) do
        create(:sleep_record, user_id: user.id, sleep_time: valid_params[:sleep_track][:sleep_time], wake_time: valid_params[:sleep_track][:wake_time], deleted_at: Time.current)
      end

      it "reactivates the deleted record" do
        post "/api/v1/sleep-track", params: valid_params

        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body, symbolize_names: true)
        expect(json_response[:message]).to eq("Sleep track record created successfully")
        expect(json_response[:sleep_track][:id]).to eq(deleted_record.id)
        expect(json_response[:sleep_track][:deleted_at]).to be_nil
      end
    end
  end
end
