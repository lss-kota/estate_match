require 'rails_helper'

RSpec.describe 'Messages', type: :request do
  let(:buyer) { create(:user, :buyer) }
  let(:owner) { create(:user, :owner) }
  let(:conversation) { create(:conversation, buyer: buyer, owner: owner) }

  describe 'POST /conversations/:conversation_id/messages' do
    let(:message_params) { { message: { content: 'Test message content' } } }

    context 'when user is participant' do
      before { sign_in buyer, scope: :user }

      context 'with valid parameters' do
        it 'creates a new message' do
          expect {
            post conversation_messages_path(conversation), params: message_params
          }.to change(Message, :count).by(1)
        end

        it 'sets current user as sender' do
          post conversation_messages_path(conversation), params: message_params
          expect(Message.last.sender).to eq(buyer)
        end

        it 'associates message with conversation' do
          post conversation_messages_path(conversation), params: message_params
          expect(Message.last.conversation).to eq(conversation)
        end

        context 'with HTML request' do
          it 'redirects to conversation' do
            post conversation_messages_path(conversation), params: message_params
            expect(response).to redirect_to(conversation)
          end

          it 'displays success message' do
            post conversation_messages_path(conversation), params: message_params
            follow_redirect!
            expect(response.body).to include('メッセージを送信しました')
          end
        end

        context 'with Ajax request' do
          it 'returns success JSON response' do
            post conversation_messages_path(conversation), 
                 params: message_params,
                 headers: { 
                   'Accept' => 'application/json',
                   'Content-Type' => 'application/json',
                   'X-Requested-With' => 'XMLHttpRequest'
                 }
            
            expect(response).to have_http_status(:success)
            
            json_response = JSON.parse(response.body)
            expect(json_response['status']).to eq('success')
            expect(json_response['message']).to eq('メッセージを送信しました')
            expect(json_response['message_html']).to be_present
          end
        end
      end

      context 'with invalid parameters' do
        let(:invalid_params) { { message: { content: '' } } }

        it 'does not create message' do
          expect {
            post conversation_messages_path(conversation), params: invalid_params
          }.not_to change(Message, :count)
        end

        context 'with HTML request' do
          it 'redirects back with error' do
            post conversation_messages_path(conversation), params: invalid_params
            expect(response).to redirect_to(conversation)
            follow_redirect!
            expect(response.body).to include('メッセージの送信に失敗しました')
          end
        end

        context 'with Ajax request' do
          it 'returns error JSON response' do
            post conversation_messages_path(conversation), 
                 params: invalid_params,
                 headers: { 'Accept' => 'application/json' }
            
            expect(response).to have_http_status(:unprocessable_content)
            
            json_response = JSON.parse(response.body)
            expect(json_response['status']).to eq('error')
            expect(json_response['errors']).to be_present
          end
        end
      end
    end

    context 'when user is not participant' do
      let(:other_user) { create(:user) }
      before { sign_in other_user, scope: :user }

      context 'with HTML request' do
        it 'redirects to conversations index' do
          post conversation_messages_path(conversation), params: message_params
          expect(response).to redirect_to(conversations_path)
        end

        it 'displays access denied message' do
          post conversation_messages_path(conversation), params: message_params
          follow_redirect!
          expect(response.body).to include('この会話にアクセスする権限がありません')
        end
      end

      context 'with Ajax request' do
        it 'returns forbidden status' do
          post conversation_messages_path(conversation), 
               params: message_params,
               headers: { 'Accept' => 'application/json' }
          
          expect(response).to have_http_status(:forbidden)
          
          json_response = JSON.parse(response.body)
          expect(json_response['status']).to eq('error')
          expect(json_response['message']).to include('この会話にアクセスする権限がありません')
        end
      end

      it 'does not create message' do
        expect {
          post conversation_messages_path(conversation), params: message_params
        }.not_to change(Message, :count)
      end
    end

    context 'when user is not signed in' do
      it 'redirects to sign in' do
        post conversation_messages_path(conversation), params: message_params
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'PATCH /conversations/:conversation_id/messages/:id/mark_as_read' do
    let(:message) { create(:message, :unread, conversation: conversation, sender: owner) }
    
    before { sign_in buyer, scope: :user }

    context 'when user is not the sender' do
      it 'marks message as read' do
        expect {
          patch mark_as_read_conversation_message_path(conversation, message)
        }.to change { message.reload.read_at }.from(nil)
      end

      context 'with Ajax request' do
        it 'returns success JSON response' do
          patch mark_as_read_conversation_message_path(conversation, message),
                headers: { 'Accept' => 'application/json' }
          
          expect(response).to have_http_status(:success)
          
          json_response = JSON.parse(response.body)
          expect(json_response['status']).to eq('success')
          expect(json_response['read_at']).to be_present
        end
      end
    end

    context 'when user is the sender' do
      let(:own_message) { create(:message, :unread, conversation: conversation, sender: buyer) }

      it 'returns error' do
        patch mark_as_read_conversation_message_path(conversation, own_message),
              headers: { 'Accept' => 'application/json' }
        
        json_response = JSON.parse(response.body)
        expect(json_response['status']).to eq('error')
        expect(json_response['message']).to include('自分のメッセージは既読にできません')
      end

      it 'does not mark message as read' do
        expect {
          patch mark_as_read_conversation_message_path(conversation, own_message)
        }.not_to change { own_message.reload.read_at }
      end
    end
  end

  describe 'PATCH /conversations/:conversation_id/messages/mark_all_read' do
    before { sign_in buyer, scope: :user }

    context 'when conversation has unread messages' do
      let!(:unread_message1) { create(:message, :unread, conversation: conversation, sender: owner) }
      let!(:unread_message2) { create(:message, :unread, conversation: conversation, sender: owner) }
      let!(:own_message) { create(:message, :unread, conversation: conversation, sender: buyer) }

      it 'marks all other users messages as read' do
        patch mark_all_read_conversation_messages_path(conversation)
        
        expect(unread_message1.reload.read_at).to be_present
        expect(unread_message2.reload.read_at).to be_present
        expect(own_message.reload.read_at).to be_nil
      end

      context 'with Ajax request' do
        it 'returns success with unread count' do
          patch mark_all_read_conversation_messages_path(conversation),
                headers: { 'Accept' => 'application/json' }
          
          expect(response).to have_http_status(:success)
          
          json_response = JSON.parse(response.body)
          expect(json_response['status']).to eq('success')
          expect(json_response['unread_count']).to eq(0)
        end
      end
    end
  end

  describe 'authorization' do
    let(:other_user) { create(:user) }
    let(:message) { create(:message, conversation: conversation) }

    context 'when user is not participant in conversation' do
      before { sign_in other_user, scope: :user }

      it 'denies access to mark_as_read' do
        patch mark_as_read_conversation_message_path(conversation, message),
              headers: { 'Accept' => 'application/json' }
        
        expect(response).to have_http_status(:forbidden)
      end

      it 'denies access to mark_all_read' do
        patch mark_all_read_conversation_messages_path(conversation),
              headers: { 'Accept' => 'application/json' }
        
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end