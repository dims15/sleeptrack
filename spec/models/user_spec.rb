require 'rails_helper'

RSpec.describe User, type: :model do
  describe "validations" do
    it "is not valid without a name" do
      user = build(:user, name: nil)
      expect(user).to_not be_valid
      expect(user.errors[:name]).to include("can't be blank")
    end

    it "is valid with a name" do
      name = "John Doe"
      user = build(:user, name: name)
      expect(user).to be_valid
      expect(user.name).to eq name
    end
  end
end
