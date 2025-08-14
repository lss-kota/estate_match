require 'rails_helper'

RSpec.describe Message, type: :model do
  describe 'associations' do
    it { should belong_to(:conversation) }
    it { should belong_to(:sender).class_name('User') }
  end

  describe 'validations' do
    it { should validate_presence_of(:content) }
    it { should validate_length_of(:content).is_at_most(1000) }
  end

  describe 'scopes' do
    let(:conversation) { create(:conversation) }
    let!(:message1) { create(:message, conversation: conversation, created_at: 2.hours.ago) }
    let!(:message2) { create(:message, conversation: conversation, created_at: 1.hour.ago) }
    let!(:read_message) { create(:message, :read, conversation: conversation) }
    let!(:unread_message) { create(:message, :unread, conversation: conversation) }

    describe '.recent' do
      it 'orders messages by created_at ascending' do
        messages = conversation.messages.recent
        expect(messages.first).to eq(message1)
        expect(messages.second).to eq(message2)
      end
    end

    describe '.unread' do
      it 'returns only unread messages' do
        unread_messages = Message.unread
        expect(unread_messages).to include(unread_message)
        expect(unread_messages).not_to include(read_message)
      end
    end
  end

  describe 'callbacks' do
    let(:conversation) { create(:conversation) }
    
    describe 'after_create' do
      it 'updates conversation last_message_at' do
        expect {
          create(:message, conversation: conversation)
        }.to change { conversation.reload.last_message_at }
      end
    end
  end

  describe 'instance methods' do
    describe '#read?' do
      context 'when read_at is present' do
        let(:message) { create(:message, :read) }
        
        it 'returns true' do
          expect(message.read?).to be true
        end
      end

      context 'when read_at is nil' do
        let(:message) { create(:message, :unread) }
        
        it 'returns false' do
          expect(message.read?).to be false
        end
      end
    end

    describe '#mark_as_read!' do
      let(:message) { create(:message, :unread) }

      context 'when message is unread' do
        it 'sets read_at to current time' do
          expect {
            message.mark_as_read!
          }.to change { message.read_at }.from(nil)
          
          expect(message.read_at).to be_within(1.second).of(Time.current)
        end
      end

      context 'when message is already read' do
        let(:read_message) { create(:message, :read) }
        let(:original_read_at) { read_message.read_at }

        it 'does not change read_at' do
          expect {
            read_message.mark_as_read!
          }.not_to change { read_message.reload.read_at }
        end
      end
    end

    describe '#sender_name' do
      let(:user) { create(:user, name: 'テストユーザー') }
      let(:message) { create(:message, sender: user) }

      it 'returns sender name' do
        expect(message.sender_name).to eq('テストユーザー')
      end
    end

    describe '#formatted_time' do
      let(:message) { create(:message, created_at: Time.zone.parse('2024-01-01 14:30:00')) }

      it 'returns formatted time as HH:MM' do
        expect(message.formatted_time).to eq('14:30')
      end
    end

    describe '#formatted_date' do
      let(:message) { create(:message) }

      context 'when message was created today' do
        before { message.update!(created_at: Time.current) }

        it 'returns "今日"' do
          expect(message.formatted_date).to eq('今日')
        end
      end

      context 'when message was created yesterday' do
        before { message.update!(created_at: Date.yesterday.end_of_day) }

        it 'returns "昨日"' do
          expect(message.formatted_date).to eq('昨日')
        end
      end

      context 'when message was created on other day' do
        before { message.update!(created_at: Time.parse('2024-01-15 10:00:00')) }

        it 'returns formatted date as MM/DD' do
          expect(message.formatted_date).to eq('01/15')
        end
      end
    end
  end

  describe 'content validation' do
    it 'accepts valid content' do
      message = build(:message, content: 'Hello, this is a test message.')
      expect(message).to be_valid
    end

    it 'rejects empty content' do
      message = build(:message, content: '')
      expect(message).not_to be_valid
      expect(message.errors[:content]).to include("can't be blank")
    end

    it 'rejects nil content' do
      message = build(:message, content: nil)
      expect(message).not_to be_valid
      expect(message.errors[:content]).to include("can't be blank")
    end

    it 'rejects content longer than 1000 characters' do
      long_content = 'a' * 1001
      message = build(:message, content: long_content)
      expect(message).not_to be_valid
      expect(message.errors[:content]).to include('is too long (maximum is 1000 characters)')
    end

    it 'accepts content exactly 1000 characters' do
      exact_content = 'a' * 1000
      message = build(:message, content: exact_content)
      expect(message).to be_valid
    end
  end
end