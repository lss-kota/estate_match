require 'rails_helper'

RSpec.describe Favorite, type: :model do
  describe 'validations' do
    subject { build(:favorite) }

    it { should validate_uniqueness_of(:user_id).scoped_to(:property_id) }
  end

  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:property) }
  end

  describe 'uniqueness constraint' do
    let(:user) { create(:user, :buyer) }
    let(:property) { create(:property) }

    it 'prevents duplicate favorites' do
      create(:favorite, user: user, property: property)
      
      duplicate_favorite = build(:favorite, user: user, property: property)
      
      expect(duplicate_favorite).not_to be_valid
      expect(duplicate_favorite.errors[:user_id]).to be_present
    end

    it 'allows same user to favorite different properties' do
      property2 = create(:property)
      
      favorite1 = create(:favorite, user: user, property: property)
      favorite2 = build(:favorite, user: user, property: property2)
      
      expect(favorite1).to be_valid
      expect(favorite2).to be_valid
    end

    it 'allows different users to favorite same property' do
      user2 = create(:user, :buyer)
      
      favorite1 = create(:favorite, user: user, property: property)
      favorite2 = build(:favorite, user: user2, property: property)
      
      expect(favorite1).to be_valid
      expect(favorite2).to be_valid
    end
  end
end