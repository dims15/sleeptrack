require 'rails_helper'

RSpec.describe Users::CreateService, type: :service do
  let(:valid_params) { { name: "John Doe" } }
  let(:invalid_params) { { name: nil } }

  describe "#execute" do
    context "with valid parameters" do
      it "creates a user and returns the user object" do
        service = described_class.new(valid_params)

        result = service.execute

        expect(result).to be_a(User)
        expect(result.name).to eq("John Doe")
        expect(result).to be_persisted
      end
    end

    context "with invalid parameters" do
      it "raises a ValidationError with errors" do
        service = described_class.new(invalid_params)

        expect { service.execute }.to raise_error(ValidationError) do |error|
          expect(error.errors).to have_key(:name)
          expect(error.errors[:name]).to include(:blank)
        end
      end
    end
  end
end
