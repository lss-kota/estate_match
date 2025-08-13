class Conversation < ApplicationRecord
  belongs_to :property
  belongs_to :buyer, class_name: 'User'
  belongs_to :owner, class_name: 'User'
  has_many :messages, dependent: :destroy

  validates :property_id, uniqueness: { 
    scope: [:buyer_id, :owner_id], 
    message: 'この物件との会話は既に存在します' 
  }

  scope :for_user, ->(user) { where('buyer_id = ? OR owner_id = ?', user.id, user.id) }
  scope :recent, -> { order(last_message_at: :desc, updated_at: :desc) }

  def other_user(current_user)
    return buyer if current_user == owner
    return owner if current_user == buyer
    nil
  end

  def last_message
    messages.order(:created_at).last
  end

  def unread_count_for(user)
    messages.where.not(sender: user).where(read_at: nil).count
  end

  def update_last_message_time!
    update!(last_message_at: Time.current)
  end

  def mark_as_read_for!(user)
    messages.where.not(sender: user).where(read_at: nil).update_all(read_at: Time.current)
  end
end