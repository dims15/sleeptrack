require 'rails_helper'

RSpec.describe Users::UnfollowService, type: :service do
  let(:user) { create(:user) }
  let(:target_user) { create(:user) }
  let(:valid_params) { { user_id: user.id, following_user_id: target_user.id } }
  let(:invalid_params) { { user_id: user.id, following_user_id: nil } }

  describe '#execute' do
    context 'when the unfollow request is valid' do
      let!(:follow_record) { create(:follow, user: user, following_user: target_user) }

      it 'successfully unfollows the target user' do
        service = described_class.new(valid_params)

        result = nil
        expect {
          result = service.execute
        }.to change { follow_record.reload.deleted_at }.from(nil)

        expect(result).to eq(follow_record)
        expect(follow_record.reload.deleted_at).not_to be_nil
      end
    end

    context 'when the user is not following the target user' do
      it 'raises a validation error' do
        service = described_class.new(valid_params)

        expect {
          service.execute
        }.to raise_error(ValidationError) do |error|
          expect(error.errors[:base]).to include("User id #{user.id} is not follow user id #{target_user.id}.")
        end
      end
    end

    context 'when the params are invalid' do
      it 'raises a validation error for missing target_user_id' do
        service = described_class.new(invalid_params)

        expect {
          service.execute
        }.to raise_error(ValidationError) do |error|
          expect(error.errors[:following_user]).to include("must exist")
          expect(error.errors[:base]).to include("Invalid user follow")
        end
      end
    end

    context 'when the unfollow action fails to update the record' do
      let!(:follow_record) { create(:follow, user: user, following_user: target_user) }

      before do
        allow_any_instance_of(Follow).to receive(:update).and_return(false)
      end

      it 'raises a validation error with update failure messages' do
        service = described_class.new(valid_params)

        expect {
          service.execute
        }.to raise_error(ValidationError) do |error|
          expect(error.errors).to include(follow_record.errors.messages)
        end
      end
    end
  end
end
