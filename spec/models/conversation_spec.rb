require 'rails_helper'

RSpec.describe Conversation, type: :model do
  describe 'associations' do
    it { should belong_to(:property) }
    it { should belong_to(:buyer).class_name('User').optional(true) }
    it { should belong_to(:owner).class_name('User') }
    it { should belong_to(:agent).class_name('User').optional(true) }
    it { should belong_to(:inquiry).optional(true) }
    it { should have_many(:messages).dependent(:destroy) }
  end

  describe 'validations' do
    subject { build(:buyer_owner_conversation) }
    
    it { should validate_uniqueness_of(:property_id).scoped_to([:buyer_id, :owner_id, :agent_id]).with_message('この組み合わせでの会話は既に存在します') }
  end

  describe 'scopes' do
    let(:user) { create(:user) }
    let(:other_user) { create(:user, :owner) }
    let!(:conversation1) { create(:buyer_owner_conversation, buyer: user, last_message_at: 1.hour.ago) }
    let!(:conversation2) { create(:buyer_owner_conversation, owner: user, last_message_at: 2.hours.ago) }
    let!(:conversation3) { create(:buyer_owner_conversation, last_message_at: 30.minutes.ago) }

    describe '.for_user' do
      it 'returns conversations where user is buyer or owner' do
        conversations = Conversation.for_user(user)
        expect(conversations).to include(conversation1, conversation2)
        expect(conversations).not_to include(conversation3)
      end
    end

    describe '.recent' do
      it 'orders by last_message_at desc, then updated_at desc' do
        conversations = Conversation.recent
        expect(conversations.first).to eq(conversation3)
        expect(conversations.second).to eq(conversation1)
        expect(conversations.third).to eq(conversation2)
      end
    end
  end

  describe 'instance methods' do
    let(:buyer) { create(:user, :buyer) }
    let(:owner) { create(:user, :owner) }
    let(:conversation) { create(:buyer_owner_conversation, buyer: buyer, owner: owner) }

    describe '#other_user' do
      context 'when current user is buyer' do
        it 'returns owner' do
          expect(conversation.other_user(buyer)).to eq(owner)
        end
      end

      context 'when current user is owner' do
        it 'returns buyer' do
          expect(conversation.other_user(owner)).to eq(buyer)
        end
      end

      context 'when current user is neither buyer nor owner' do
        let(:other_user) { create(:user) }
        
        it 'returns nil' do
          expect(conversation.other_user(other_user)).to be_nil
        end
      end
    end

    describe '#last_message' do
      context 'when conversation has messages' do
        let!(:message1) { create(:message, conversation: conversation, created_at: 2.hours.ago) }
        let!(:message2) { create(:message, conversation: conversation, created_at: 1.hour.ago) }
        
        it 'returns the most recent message' do
          expect(conversation.last_message).to eq(message2)
        end
      end

      context 'when conversation has no messages' do
        it 'returns nil' do
          expect(conversation.last_message).to be_nil
        end
      end
    end

    describe '#unread_count_for' do
      let!(:read_message) { create(:message, :read, conversation: conversation, sender: owner) }
      let!(:unread_message1) { create(:message, :unread, conversation: conversation, sender: owner) }
      let!(:unread_message2) { create(:message, :unread, conversation: conversation, sender: owner) }
      let!(:own_message) { create(:message, :unread, conversation: conversation, sender: buyer) }

      it 'returns count of unread messages from other users' do
        expect(conversation.unread_count_for(buyer)).to eq(2)
      end

      it 'does not count own messages' do
        # ownerの未読メッセージ数は、buyer が送信した未読メッセージの数
        expect(conversation.unread_count_for(owner)).to eq(1)
      end
    end

    describe '#update_last_message_time!' do
      it 'updates last_message_at to current time' do
        old_time = conversation.last_message_at
        
        travel_to 1.hour.from_now do
          conversation.update_last_message_time!
          expect(conversation.last_message_at).to be > old_time
        end
      end
    end

    describe '#mark_as_read_for!' do
      let!(:unread_message1) { create(:message, :unread, conversation: conversation, sender: owner) }
      let!(:unread_message2) { create(:message, :unread, conversation: conversation, sender: owner) }
      let!(:own_message) { create(:message, :unread, conversation: conversation, sender: buyer) }

      it 'marks all unread messages from others as read' do
        expect {
          conversation.mark_as_read_for!(buyer)
        }.to change { conversation.messages.where.not(sender: buyer).where(read_at: nil).count }.from(2).to(0)
      end

      it 'does not mark own messages as read' do
        conversation.mark_as_read_for!(buyer)
        expect(own_message.reload.read_at).to be_nil
      end
    end
  end

  describe 'uniqueness validation' do
    let(:property) { create(:property) }
    let(:buyer) { create(:user, :buyer) }
    let(:owner) { create(:user, :owner) }

    it 'prevents duplicate conversations for same property, buyer, and owner' do
      create(:buyer_owner_conversation, property: property, buyer: buyer, owner: owner)
      
      duplicate_conversation = build(:buyer_owner_conversation, property: property, buyer: buyer, owner: owner)
      expect(duplicate_conversation).not_to be_valid
      expect(duplicate_conversation.errors[:property_id]).to include('この組み合わせでの会話は既に存在します')
    end

    it 'allows conversations with different properties' do
      property1 = create(:property)
      property2 = create(:property)
      
      create(:buyer_owner_conversation, property: property1, buyer: buyer, owner: owner)
      conversation2 = build(:buyer_owner_conversation, property: property2, buyer: buyer, owner: owner)
      
      expect(conversation2).to be_valid
    end

    it 'allows conversations with different users' do
      buyer2 = create(:user, :buyer)
      
      create(:buyer_owner_conversation, property: property, buyer: buyer, owner: owner)
      conversation2 = build(:buyer_owner_conversation, property: property, buyer: buyer2, owner: owner)
      
      expect(conversation2).to be_valid
    end
  end

  describe 'agent property limit validation' do
    let(:membership_plan) { create(:membership_plan, monthly_property_limit: 2) }
    let(:agent) { create(:user, :agent, membership_plan: membership_plan) }
    let(:owner) { create(:user, :owner) }
    let(:property1) { create(:property, user: owner) }
    let(:property2) { create(:property, user: owner) }
    let(:property3) { create(:property, user: owner) }

    context 'when agent is within monthly property limit' do
      before do
        travel_to Time.current.beginning_of_month + 1.day do
          create(:agent_owner_conversation, agent: agent, owner: owner, property: property1)
        end
      end

      it 'allows creating new conversation for different property' do
        travel_to Time.current.beginning_of_month + 1.day do
          conversation = build(:agent_owner_conversation, agent: agent, owner: owner, property: property2)
          expect(conversation).to be_valid
        end
      end
    end

    context 'when agent has reached monthly property limit' do
      before do
        travel_to Time.current.beginning_of_month + 1.day do
          create(:agent_owner_conversation, agent: agent, owner: owner, property: property1)
          create(:agent_owner_conversation, agent: agent, owner: owner, property: property2)
        end
      end

      it 'prevents creating conversation for new property' do
        travel_to Time.current.beginning_of_month + 1.day do
          conversation = build(:agent_owner_conversation, agent: agent, owner: owner, property: property3)
          expect(conversation).not_to be_valid
          expect(conversation.errors[:base]).to include("月間の物件メッセージ制限（2物件）を超過しています")
        end
      end
    end

    context 'when agent has conversations from previous month' do
      before do
        travel_to 1.month.ago do
          create(:agent_owner_conversation, agent: agent, owner: owner, property: property1)
          create(:agent_owner_conversation, agent: agent, owner: owner, property: property2)
        end
      end

      it 'allows creating new conversation in current month' do
        travel_to Time.current.beginning_of_month + 1.day do
          conversation = build(:agent_owner_conversation, agent: agent, owner: owner, property: property3)
          expect(conversation).to be_valid
        end
      end
    end

    context 'when conversation is not agent_owner type' do
      it 'does not apply property limit validation' do
        conversation = build(:buyer_owner_conversation, buyer: agent, owner: owner, property: property1)
        expect(conversation).to be_valid
      end
    end

    context 'when agent has no membership plan' do
      it 'prevents creating any conversation' do
        # membership_planなしで保存するため、一時的にvalidationをバイパス
        agent_without_plan = User.new(
          user_type: :agent,
          email: "test@example.com",
          password: "password",
          name: "Test Agent",
          company_name: "Test Company",
          license_number: "TEST123"
        )
        agent_without_plan.save!(validate: false)
        
        conversation = build(:conversation, 
          conversation_type: :agent_owner,
          owner: owner, 
          property: property1,
          agent_id: agent_without_plan.id
        )
        conversation.agent = agent_without_plan
        expect(conversation).not_to be_valid
        expect(conversation.errors[:base]).to include("月間の物件メッセージ制限（0物件）を超過しています")
      end
    end
  end
end