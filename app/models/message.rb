class Message < ApplicationRecord
  belongs_to :conversation
  belongs_to :sender, class_name: 'User'

  validates :content, presence: true, length: { maximum: 1000 }

  scope :recent, -> { order(:created_at) }
  scope :unread, -> { where(read_at: nil) }

  after_create :update_conversation_timestamp
  after_create :broadcast_message

  def read?
    read_at.present?
  end

  def mark_as_read!
    update!(read_at: Time.current) unless read?
  end

  def sender_name
    sender.name
  end

  def formatted_time
    created_at.strftime('%H:%M')
  end

  def formatted_date
    if created_at.today?
      '今日'
    elsif created_at.to_date == Date.yesterday
      '昨日'
    else
      created_at.strftime('%m/%d')
    end
  end

  private

  def update_conversation_timestamp
    conversation.update_last_message_time!
  end

  def broadcast_message
    message_data = {
      id: id,
      content: content,
      sender_id: sender.id,
      sender_name: sender_name,
      formatted_time: formatted_time,
      formatted_date: formatted_date,
      created_at: created_at
    }

    message_html = ApplicationController.render(
      partial: 'messages/message',
      locals: { message: self, current_user: nil },
      formats: [:html]
    )

    # 会話チャンネルにメッセージを配信
    ActionCable.server.broadcast "conversation_#{conversation.id}", {
      type: 'new_message',
      message: message_data,
      message_html: message_html
    }

    # 受信者への通知を配信（送信者以外）
    recipient = conversation.buyer == sender ? conversation.owner : conversation.buyer
    ActionCable.server.broadcast "user_notifications_#{recipient.id}", {
      type: 'new_message',
      conversation_id: conversation.id,
      message: message_data,
      sender_name: sender_name
    }
  end
end