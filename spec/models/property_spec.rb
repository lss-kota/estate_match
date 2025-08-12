require 'rails_helper'

RSpec.describe Property, type: :model do
  describe 'validations' do
    subject { build(:property) }

    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:property_type) }
    it { should validate_presence_of(:prefecture) }
    it { should validate_presence_of(:city) }
    it { should validate_presence_of(:status) }
  end

  describe 'associations' do
    it { should belong_to(:user) }
    it { should have_many(:favorites).dependent(:destroy) }
    it { should have_many(:favorited_by_users).through(:favorites).source(:user) }
  end

  describe 'methods' do
    let(:property) { create(:property) }
    let(:buyer) { create(:user, :buyer) }

    describe '#favorited_by?' do
      context 'when user has favorited the property' do
        before { create(:favorite, user: buyer, property: property) }

        it 'returns true' do
          expect(property.favorited_by?(buyer)).to be true
        end
      end

      context 'when user has not favorited the property' do
        it 'returns false' do
          expect(property.favorited_by?(buyer)).to be false
        end
      end

      context 'when user is nil' do
        it 'returns false' do
          expect(property.favorited_by?(nil)).to be false
        end
      end
    end

    describe '#favorites_count' do
      before do
        create_list(:favorite, 3, property: property)
      end

      it 'returns the correct count of favorites' do
        expect(property.favorites_count).to eq(3)
      end
    end
  end

  describe 'scopes' do
    before do
      create(:property, :sold)
      create(:property, :rented)
      create(:property, :draft)
      create(:property) # active
    end

    describe '.active' do
      it 'returns only active properties' do
        expect(Property.active.count).to eq(1)
        expect(Property.active.first.status).to eq('active')
      end
    end

    describe '.house' do
      before { create(:property, :vacant_land) }

      it 'returns only house properties' do
        expect(Property.house.count).to eq(4)
        Property.house.each do |property|
          expect(property.property_type).to eq('house')
        end
      end
    end

    describe '.land' do
      before { create(:property, :vacant_land) }

      it 'returns only land properties' do
        expect(Property.land.count).to eq(1)
        expect(Property.land.first.property_type).to eq('land')
      end
    end
  end
end