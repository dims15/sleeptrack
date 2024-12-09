require 'rails_helper'

RSpec.describe "Api::V1::Users", type: :request do
  describe "POST /api/v1/users" do
    let(:valid_params) { { user: { name: "John Doe" } } }
    let(:invalid_params) { { user: { name: nil } } }

    context "when the request is valid" do
      it "creates a user and returns a success message" do
        post '/api/v1/users', params: valid_params

        expect(response).to have_http_status(:created)

        json_response = JSON.parse(response.body)
        expect(json_response['message']).to eq("User created successfully")
        expect(json_response['user']['name']).to eq("John Doe")
      end
    end

    context "when the request is invalid" do
      it "returns a validation error message" do
        post '/api/v1/users', params: invalid_params

        expect(response.status).to eq(422)

        json_response = JSON.parse(response.body)
        expect(json_response['message']).to eq("Validation failed")
        expect(json_response['errors']['name']).to include("can't be blank")
      end
    end
  end
end
