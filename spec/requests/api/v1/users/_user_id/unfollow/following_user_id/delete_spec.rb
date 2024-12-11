require 'rails_helper'

RSpec.describe 'Api::V1::UsersController', type: :request do
  describe "DELETE /api/v1/users/:user_id/unfollow/:following_user_id" do
    let(:user) { create(:user) }
    let(:following_user) { create(:user) }
    let!(:follow) { create(:follow, user: user, following_user: following_user, deleted_at: nil) }

    context "when the unfollow request is valid" do
      it "unfollows the user and returns success response" do
        delete "/api/v1/users/#{user.id}/unfollow/#{following_user.id}"

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body["message"]).to eq("User unfollowed")
        expect(response.parsed_body["unfollow"]["id"]).to eq(follow.id)
        expect(follow.reload.deleted_at).not_to be_nil
      end
    end

    context "when the user is not following the target user" do
      before { follow.update(deleted_at: Time.current) }

      it "returns an error response" do
        delete "/api/v1/users/#{user.id}/unfollow/#{following_user.id}"

        expect(response.status).to eq(422)
        expect(response.parsed_body["errors"]['base']).to include("User id #{user.id} is not follow user id #{following_user.id}.")
      end
    end

    context "when the request is invalid" do
      it "returns an error not found if user_id is missing" do
        delete "/api/v1/users/abc/unfollow/#{following_user.id}"

        expect(response.status).to eq(422)
        expect(response.parsed_body["errors"]['user']).to include("must exist")
      end

      it "returns an error not found if following_user_id is missing" do
        delete "/api/v1/users/#{user.id}/unfollow/abc", params: { user_id: user.id }

        expect(response.status).to eq(422)
        expect(response.parsed_body["errors"]['following_user']).to include("must exist")
      end
    end
  end
end
