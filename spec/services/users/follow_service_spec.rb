require 'rails_helper'

RSpec.describe Users::FollowService, type: :service do
  describe '#execute' do
    let(:user) { create(:user) }
    let(:target_user) { create(:user) }
    let(:params) { { user_id: user.id, following_user_id: target_user.id } }

    context 'when the follow does not already exist' do
      it 'creates a new follow relationship' do
        service = described_class.new(params)

        expect { service.execute }.to change(Follow, :count).by(1)
      end
    end

    context 'when the user is already following the target user' do
      before { create(:follow, user: user, following_user: target_user) }

      it 'raises a validation error for already following' do
        service = described_class.new(params)

        expect { service.execute }.to raise_error(ValidationError)
      end
    end

    context 'when a follow relationship has been deleted and restored' do
      before do
        create(:follow, user: user, following_user: target_user, deleted_at: Time.current)
      end

      it 'restores the deleted follow record' do
        service = described_class.new(params)

        expect { service.execute }.to change { Follow.where(user: user, following_user: target_user).first.deleted_at }.to(nil)
      end
    end
  end
end
