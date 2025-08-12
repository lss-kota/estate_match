require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    subject { build(:user) }

    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:user_type) }
    it { should validate_uniqueness_of(:email).case_insensitive }
  end

  describe 'associations' do
    it { should have_many(:properties).dependent(:destroy) }
    it { should have_many(:favorites).dependent(:destroy) }
    it { should have_many(:favorite_properties).through(:favorites).source(:property) }
  end

  describe 'methods' do
    let(:user) { create(:user) }

    describe '#owner?' do
      context 'when user_type is owner' do
        let(:owner) { create(:user, :owner) }
        
        it 'returns true' do
          expect(owner.owner?).to be true
        end
      end

      context 'when user_type is buyer' do
        let(:buyer) { create(:user, :buyer) }
        
        it 'returns false' do
          expect(buyer.owner?).to be false
        end
      end
    end

    describe '#buyer?' do
      context 'when user_type is buyer' do
        let(:buyer) { create(:user, :buyer) }
        
        it 'returns true' do
          expect(buyer.buyer?).to be true
        end
      end

      context 'when user_type is owner' do
        let(:owner) { create(:user, :owner) }
        
        it 'returns false' do
          expect(owner.buyer?).to be false
        end
      end
    end
  end
end