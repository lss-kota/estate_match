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
    it { should belong_to(:membership_plan).optional }
    it { should have_many(:agent_partnerships).dependent(:destroy) }
    it { should have_many(:owner_partnerships).dependent(:destroy) }
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

    describe '#agent?' do
      context 'when user_type is agent' do
        let(:agent) { create(:user, :agent) }
        
        it 'returns true' do
          expect(agent.agent?).to be true
        end
      end

      context 'when user_type is buyer' do
        let(:buyer) { create(:user, :buyer) }
        
        it 'returns false' do
          expect(buyer.agent?).to be false
        end
      end
    end

    describe 'agent property limit functionality' do
      let(:membership_plan) { create(:membership_plan, monthly_property_limit: 3) }
      let(:agent) { create(:user, :agent, membership_plan: membership_plan) }
      let(:owner) { create(:user, :owner) }
      let!(:property1) { create(:property, user: owner) }
      let!(:property2) { create(:property, user: owner) }
      let!(:property3) { create(:property, user: owner) }
      let!(:property4) { create(:property, user: owner) }

      describe '#monthly_property_count' do
        it 'returns 0 for non-agent users' do
          expect(owner.monthly_property_count).to eq(0)
        end

        context 'when agent has no conversations this month' do
          it 'returns 0' do
            expect(agent.monthly_property_count).to eq(0)
          end
        end

        context 'when agent has conversations with different properties' do
          before do
            # 今月の会話を作成
            travel_to Time.current.beginning_of_month + 1.day do
              create(:agent_owner_conversation, agent: agent, owner: owner, property: property1)
              create(:agent_owner_conversation, agent: agent, owner: owner, property: property2)
            end
          end

          it 'counts unique properties' do
            travel_to Time.current.beginning_of_month + 1.day do
              expect(agent.monthly_property_count).to eq(2)
            end
          end
        end

        context 'when agent has multiple conversations with same property' do
          before do
            travel_to Time.current.beginning_of_month + 1.day do
              # 同じ物件に対して複数の会話（実際には制約により1つだけ作成される）
              create(:agent_owner_conversation, agent: agent, owner: owner, property: property1)
            end
          end

          it 'counts same property only once' do
            travel_to Time.current.beginning_of_month + 1.day do
              expect(agent.monthly_property_count).to eq(1)
            end
          end
        end

        context 'when agent has conversations from previous month' do
          before do
            # 先月の会話
            travel_to 1.month.ago do
              create(:agent_owner_conversation, agent: agent, owner: owner, property: property1)
            end
            # 今月の会話
            travel_to Time.current.beginning_of_month + 1.day do
              create(:agent_owner_conversation, agent: agent, owner: owner, property: property2)
            end
          end

          it 'only counts current month conversations' do
            travel_to Time.current.beginning_of_month + 1.day do
              expect(agent.monthly_property_count).to eq(1)
            end
          end
        end
      end

      describe '#monthly_property_limit' do
        it 'returns membership plan limit for agents' do
          expect(agent.monthly_property_limit).to eq(3)
        end

        it 'returns 0 for agents without membership plan' do
          agent_without_plan = build(:user, :agent, membership_plan: nil)
          expect(agent_without_plan.monthly_property_limit).to eq(0)
        end

        it 'returns 0 for non-agent users' do
          expect(owner.monthly_property_limit).to eq(0)
        end
      end

      describe '#can_start_new_conversation?' do
        context 'when agent is within property limit' do
          before do
            travel_to Time.current.beginning_of_month + 1.day do
              # 制限内の会話を作成 (2/3)
              create(:agent_owner_conversation, agent: agent, owner: owner, property: property1)
              create(:agent_owner_conversation, agent: agent, owner: owner, property: property2)
            end
          end

          it 'returns true' do
            travel_to Time.current.beginning_of_month + 1.day do
              expect(agent.can_start_new_conversation?).to be true
            end
          end
        end

        context 'when agent has reached property limit' do
          before do
            travel_to Time.current.beginning_of_month + 1.day do
              # 制限まで会話を作成 (3/3)
              create(:agent_owner_conversation, agent: agent, owner: owner, property: property1)
              create(:agent_owner_conversation, agent: agent, owner: owner, property: property2)
              create(:agent_owner_conversation, agent: agent, owner: owner, property: property3)
            end
          end

          it 'returns false' do
            travel_to Time.current.beginning_of_month + 1.day do
              expect(agent.can_start_new_conversation?).to be false
            end
          end
        end

        it 'returns false for non-agent users' do
          expect(owner.can_start_new_conversation?).to be false
        end

        it 'returns false for agents without membership plan' do
          agent_without_plan = build(:user, :agent, membership_plan: nil)
          expect(agent_without_plan.can_start_new_conversation?).to be false
        end
      end

      describe '#monthly_property_limit_exceeded?' do
        context 'when agent is within limit' do
          before do
            travel_to Time.current.beginning_of_month + 1.day do
              create(:agent_owner_conversation, agent: agent, owner: owner, property: property1)
            end
          end

          it 'returns false' do
            travel_to Time.current.beginning_of_month + 1.day do
              expect(agent.monthly_property_limit_exceeded?).to be false
            end
          end
        end

        context 'when agent has exceeded limit' do
          before do
            travel_to Time.current.beginning_of_month + 1.day do
              create(:agent_owner_conversation, agent: agent, owner: owner, property: property1)
              create(:agent_owner_conversation, agent: agent, owner: owner, property: property2)
              create(:agent_owner_conversation, agent: agent, owner: owner, property: property3)
            end
          end

          it 'returns true' do
            travel_to Time.current.beginning_of_month + 1.day do
              expect(agent.monthly_property_limit_exceeded?).to be true
            end
          end
        end

        it 'returns false for non-agent users' do
          expect(owner.monthly_property_limit_exceeded?).to be false
        end
      end
    end
  end
end