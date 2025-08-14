class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_conversation
  before_action :ensure_participant!

  # POST /conversations/:conversation_id/messages
  # メッセージ送信
  def create
    @message = @conversation.messages.build(message_params)
    @message.sender = current_user

    if @message.save
      # Ajax request の場合
      if ajax_request?
        render json: {
          status: 'success',
          message_html: render_to_string(
            partial: 'messages/message',
            locals: { message: @message, current_user: current_user },
            formats: [:html]
          )
        }
      else
        redirect_to @conversation
      end
    else
      if ajax_request?
        render json: {
          status: 'error',
          errors: @message.errors.full_messages
        }, status: :unprocessable_content
      else
        redirect_to @conversation, alert: 'メッセージの送信に失敗しました。'
      end
    end
  end

  # PATCH /conversations/:conversation_id/messages/:id/read
  # メッセージを既読にする
  def mark_as_read
    @message = @conversation.messages.find(params[:id])
    
    # 送信者以外のユーザーのみ既読可能
    if @message.sender != current_user
      @message.mark_as_read!
      
      if ajax_request?
        render json: { status: 'success', read_at: @message.read_at }
      else
        redirect_back(fallback_location: @conversation)
      end
    else
      render json: { status: 'error', message: '自分のメッセージは既読にできません' }
    end
  end

  # PATCH /conversations/:conversation_id/messages/mark_all_read
  # 会話内の全未読メッセージを既読にする
  def mark_all_read
    @conversation.mark_as_read_for!(current_user)
    
    if ajax_request?
      render json: { 
        status: 'success', 
        unread_count: @conversation.unread_count_for(current_user) 
      }
    else
      redirect_back(fallback_location: @conversation)
    end
  end

  private

  def set_conversation
    @conversation = Conversation.find(params[:conversation_id])
  end

  def ensure_participant!
    unless @conversation.buyer == current_user || @conversation.owner == current_user
      if ajax_request?
        render json: { 
          status: 'error', 
          message: 'この会話にアクセスする権限がありません' 
        }, status: :forbidden
      else
        redirect_to conversations_path, alert: 'この会話にアクセスする権限がありません。'
      end
    end
  end

  def message_params
    params.require(:message).permit(:content)
  end

  def ajax_request?
    request.xhr? || 
    request.headers['Accept']&.include?('application/json') ||
    request.headers['X-Requested-With'] == 'XMLHttpRequest'
  end
end