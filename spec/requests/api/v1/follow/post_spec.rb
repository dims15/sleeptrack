require 'rails_helper'

RSpec.describe 'Api::V1::UsersController', type: :request do
  let(:user) { create(:user) }
  let(:target_user) { create(:user) }

  describe 'POST /api/v1/follow' do
    context 'when the params are valid' do
      it 'successfully follows the target user' do
        expect {
          post "/api/v1/users/#{user.id}/follow/#{target_user.id}", headers: { 'Content-Type' => 'application/json' }
        }.to change(Follow, :count).by(1)

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['message']).to eq('User followed')
        expect(json['follow']).to be_present
      end
    end

    context 'when the user tries to follow themselves' do
      it 'returns an error' do
        post "/api/v1/users/#{user.id}/follow/#{user.id}", headers: { 'Content-Type' => 'application/json' }

        expect(response.status).to eq(422)
        json = JSON.parse(response.body)
        expect(json['errors']['base']).to include('Cannot follow or unfollow yourself')
      end
    end

    context 'when the target user id is invalid' do
      it 'returns an error' do
        post "/api/v1/users/#{user.id}/follow/abc", headers: { 'Content-Type' => 'application/json' }

        expect(response.status).to eq(422)
        json = JSON.parse(response.body)
        expect(json['errors']['following_user']).to include('must exist')
      end
    end

    context 'when the user is already following the target user' do
      before { create(:follow, user: user, following_user: target_user) }

      it 'does not create a duplicate follow relationship' do
        post "/api/v1/users/#{user.id}/follow/#{target_user.id}", headers: { 'Content-Type' => 'application/json' }

        expect(response.status).to eq(422)
        json = JSON.parse(response.body)
        expect(json['errors']['base']).to include('User already following this account')
      end
    end
  end
end
