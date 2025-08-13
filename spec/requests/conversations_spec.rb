require 'rails_helper'

RSpec.describe 'Conversations', type: :request do
  let(:buyer) { create(:user, :buyer) }
  let(:owner) { create(:user, :owner) }
  let(:property) { create(:property, user: owner) }
  let(:conversation) { create(:conversation, property: property, buyer: buyer, owner: owner) }

  describe 'GET /conversations' do
    context 'when user is signed in' do
      before { sign_in buyer, scope: :user }

      context 'when user has conversations' do
        let!(:conversation1) { create(:conversation, buyer: buyer) }
        let!(:conversation2) { create(:conversation, owner: buyer) }
        let!(:other_conversation) { create(:conversation) }

        it 'returns successful response' do
          get conversations_path
          expect(response).to have_http_status(:success)
        end

        it 'displays user conversations' do
          get conversations_path
          expect(response.body).to include(conversation1.property.title)
          expect(response.body).to include(conversation2.property.title)
          expect(response.body).not_to include(other_conversation.property.title)
        end
      end

      context 'when user has no conversations' do
        it 'returns successful response' do
          get conversations_path
          expect(response).to have_http_status(:success)
        end
      end
    end

    context 'when user is not signed in' do
      it 'redirects to sign in' do
        get conversations_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'GET /conversations/:id' do
    before { sign_in buyer, scope: :user }

    context 'when user is participant' do
      let!(:messages) { create_list(:message, 3, conversation: conversation) }

      it 'returns successful response' do
        get conversation_path(conversation)
        expect(response).to have_http_status(:success)
      end

      it 'displays conversation messages' do
        get conversation_path(conversation)
        messages.each do |message|
          expect(response.body).to include(message.content)
        end
      end

      it 'marks messages as read for current user' do
        unread_message = create(:message, :unread, conversation: conversation, sender: owner)
        
        expect {
          get conversation_path(conversation)
        }.to change { unread_message.reload.read_at }.from(nil)
      end
    end

    context 'when user is not participant' do
      let(:other_user) { create(:user) }
      before { sign_in other_user, scope: :user }

      it 'redirects to conversations index' do
        get conversation_path(conversation)
        expect(response).to redirect_to(conversations_path)
      end

      it 'displays access denied message' do
        get conversation_path(conversation)
        follow_redirect!
        expect(response.body).to include('この会話にアクセスする権限がありません')
      end
    end

    context 'when user is not signed in' do
      it 'redirects to sign in' do
        get conversation_path(conversation)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'POST /conversations' do
    before { sign_in buyer, scope: :user }

    context 'when buyer wants to message about property' do
      context 'when conversation does not exist' do
        it 'creates new conversation' do
          expect {
            post conversations_path, params: { property_id: property.id }
          }.to change(Conversation, :count).by(1)
        end

        it 'redirects to conversation' do
          post conversations_path, params: { property_id: property.id }
          expect(response).to redirect_to(assigns(:conversation))
        end

        it 'displays success message' do
          post conversations_path, params: { property_id: property.id }
          follow_redirect!
          expect(response.body).to include('メッセージを開始しました')
        end
      end

      context 'when conversation already exists' do
        let!(:existing_conversation) { create(:conversation, property: property, buyer: buyer, owner: owner) }

        it 'does not create new conversation' do
          expect {
            post conversations_path, params: { property_id: property.id }
          }.not_to change(Conversation, :count)
        end

        it 'redirects to existing conversation' do
          post conversations_path, params: { property_id: property.id }
          expect(response).to redirect_to(existing_conversation)
        end
      end
    end

    context 'when owner tries to message about own property' do
      before { sign_in owner, scope: :user }

      it 'redirects to property with error' do
        post conversations_path, params: { property_id: property.id }
        expect(response).to redirect_to(property)
        follow_redirect!
        expect(response.body).to include('この物件へのお問い合わせはできません')
      end

      it 'does not create conversation' do
        expect {
          post conversations_path, params: { property_id: property.id }
        }.not_to change(Conversation, :count)
      end
    end

    context 'when user is not signed in' do
      it 'redirects to sign in' do
        post conversations_path, params: { property_id: property.id }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'DELETE /conversations/:id' do
    before { sign_in buyer, scope: :user }

    context 'when user is participant' do
      it 'deletes conversation' do
        conversation # create conversation
        expect {
          delete conversation_path(conversation)
        }.to change(Conversation, :count).by(-1)
      end

      it 'redirects to conversations index' do
        delete conversation_path(conversation)
        expect(response).to redirect_to(conversations_path)
      end

      it 'displays success message' do
        delete conversation_path(conversation)
        follow_redirect!
        expect(response.body).to include('会話を削除しました')
      end
    end

    context 'when user is not participant' do
      let(:other_user) { create(:user) }
      before { sign_in other_user, scope: :user }

      it 'redirects to conversations index' do
        delete conversation_path(conversation)
        expect(response).to redirect_to(conversations_path)
      end

      it 'does not delete conversation' do
        conversation # create conversation
        expect {
          delete conversation_path(conversation)
        }.not_to change(Conversation, :count)
      end
    end

    context 'when user is not signed in' do
      it 'redirects to sign in' do
        delete conversation_path(conversation)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end