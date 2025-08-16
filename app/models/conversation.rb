class Conversation < ApplicationRecord
  belongs_to :property
  belongs_to :buyer, class_name: 'User', optional: true
  belongs_to :owner, class_name: 'User'
  belongs_to :agent, class_name: 'User', optional: true
  belongs_to :inquiry, optional: true
  has_many :messages, dependent: :destroy

  enum :conversation_type, {
    buyer_owner: 0,        # 従来の買い手-オーナー間会話（廃止予定）
    agent_owner: 1,        # 不動産業者-オーナー間会話
    agent_buyer_inquiry: 2 # 問い合わせから始まる3者間会話
  }

  # バリデーション
  validates :property_id, uniqueness: { 
    scope: [:buyer_id, :owner_id, :agent_id], 
    message: 'この組み合わせでの会話は既に存在します' 
  }
  
  validate :validate_conversation_type_participants
  validate :validate_agent_property_limit, if: -> { conversation_type == 'agent_owner' }

  scope :for_user, ->(user) { 
    where('buyer_id = ? OR owner_id = ? OR agent_id = ?', user.id, user.id, user.id) 
  }
  scope :recent, -> { order(last_message_at: :desc, updated_at: :desc) }
  scope :agent_conversations, ->(agent) { where(agent: agent) }

  # 現在のユーザーと会話している相手を取得
  def other_users(current_user)
    participants = []
    
    case conversation_type
    when 'agent_owner'
      participants << (current_user == agent ? owner : agent) if current_user.in?([agent, owner])
    when 'agent_buyer_inquiry'
      if current_user == agent
        participants = [buyer, owner].compact
      elsif current_user == buyer
        participants = [agent].compact
      elsif current_user == owner
        participants = [agent].compact
      end
    when 'buyer_owner' # 廃止予定だが既存データのため残す
      participants << (current_user == buyer ? owner : buyer) if current_user.in?([buyer, owner])
    end
    
    participants
  end
  
  # 主要な相手ユーザーを取得（従来のother_userメソッド互換）
  def other_user(current_user)
    other_users(current_user).first
  end
  
  # 会話の参加者全員を取得
  def participants
    case conversation_type
    when 'agent_owner'
      [agent, owner].compact
    when 'agent_buyer_inquiry'
      [agent, buyer, owner].compact
    when 'buyer_owner'
      [buyer, owner].compact
    else
      []
    end
  end
  
  # 会話のタイトルを取得
  def display_title(current_user = nil)
    case conversation_type
    when 'agent_owner'
      if current_user == agent
        "#{owner.name}との相談 - #{property.title}"
      else
        "#{agent.display_name}との相談 - #{property.title}"
      end
    when 'agent_buyer_inquiry'
      if current_user == agent
        "#{buyer.name}からの問い合わせ - #{property.title}"
      elsif current_user == buyer
        "#{agent.display_name}への問い合わせ - #{property.title}"
      else
        "#{agent.display_name}経由の問い合わせ - #{property.title}"
      end
    else
      property.title
    end
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
  
  private
  
  # 会話タイプに応じた参加者の妥当性をチェック
  def validate_conversation_type_participants
    case conversation_type
    when 'agent_owner'
      if agent.blank? || owner.blank?
        errors.add(:base, '不動産業者-オーナー間会話には両方のユーザーが必要です')
      end
      if agent.present? && !agent.agent?
        errors.add(:agent, 'は不動産業者である必要があります')
      end
      if owner.present? && !owner.owner?
        errors.add(:owner, 'はオーナーである必要があります')
      end
    when 'agent_buyer_inquiry'
      if agent.blank? || buyer.blank? || inquiry.blank?
        errors.add(:base, '問い合わせ会話には不動産業者、購買者、問い合わせが必要です')
      end
      if agent.present? && !agent.agent?
        errors.add(:agent, 'は不動産業者である必要があります')
      end
      if buyer.present? && !buyer.buyer?
        errors.add(:buyer, 'は購買者である必要があります')
      end
    when 'buyer_owner'
      # 廃止予定のため警告のみ
      Rails.logger.warn "buyer_owner conversation type is deprecated"
    end
  end
  
  # 不動産業者の月間メッセージ制限をチェック
  def validate_agent_property_limit
    return unless agent&.agent?
    
    # membership_planがない場合は制限0として扱う
    limit = agent.membership_plan&.monthly_property_limit || 0
    
    # 今月の会話開始数をチェック
    # 今月メッセージした物件数をカウント
    monthly_property_count = Conversation.where(conversation_type: :agent_owner)
      .where(agent: agent)
      .where(created_at: Time.current.beginning_of_month..Time.current.end_of_month)
      .distinct
      .count(:property_id)
    
    if monthly_property_count >= limit
      errors.add(:base, "月間の物件メッセージ制限（#{limit}物件）を超過しています")
    end
  end
end