class ConversationChannel < ApplicationCable::Channel
  def subscribed
    # ユーザーが会話の参加者かどうかを確認
    conversation = Conversation.find(params[:conversation_id])
    
    if authorized_for_conversation?(conversation)
      stream_from "conversation_#{conversation.id}"
      Rails.logger.info "User #{current_user.id} subscribed to conversation #{conversation.id}"
    else
      reject
      Rails.logger.warn "User #{current_user.id} unauthorized for conversation #{conversation.id}"
    end
  end

  def unsubscribed
    Rails.logger.info "User #{current_user&.id} unsubscribed from conversation channel"
  end

  def mark_as_read(data)
    message = Message.find(data['message_id'])
    conversation = message.conversation
    
    if authorized_for_conversation?(conversation) && message.sender != current_user
      message.mark_as_read!
      
      # 既読状態を他のクライアントに通知
      ActionCable.server.broadcast "conversation_#{conversation.id}", {
        type: 'message_read',
        message_id: message.id,
        read_at: message.read_at,
        reader_id: current_user.id
      }
    end
  end

  private

  def authorized_for_conversation?(conversation)
    conversation.buyer == current_user || conversation.owner == current_user
  end
end