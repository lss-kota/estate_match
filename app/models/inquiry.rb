class Inquiry < ApplicationRecord
  # アソシエーション
  belongs_to :property
  belongs_to :buyer, class_name: 'User'
  belongs_to :agent, class_name: 'User'

  # ステータスの定義
  enum :status, {
    pending: 0,     # 問い合わせ待ち
    contacted: 1,   # 連絡済み
    closed: 2       # 完了
  }

  # バリデーション
  validates :property_id, presence: true
  validates :buyer_id, presence: true
  validates :agent_id, presence: true
  validates :message, presence: true, length: { maximum: 2000 }
  validates :buyer_id, uniqueness: { scope: :property_id }

  # カスタムバリデーション
  validate :validate_user_types

  # スコープ
  scope :pending, -> { where(status: :pending) }
  scope :contacted, -> { where(status: :contacted) }
  scope :for_agent, ->(agent_id) { where(agent_id: agent_id) }
  scope :for_property, ->(property_id) { where(property_id: property_id) }
  scope :recent, -> { order(created_at: :desc) }

  # メソッド
  def mark_contacted!
    update!(status: :contacted, contacted_at: Time.current)
  end

  def mark_closed!
    update!(status: :closed, closed_at: Time.current)
  end

  def response_time_hours
    return 0 unless contacted_at
    ((contacted_at - created_at) / 1.hour).round(1)
  end

  def days_since_inquiry
    ((Time.current - created_at) / 1.day).round
  end

  private

  def validate_user_types
    if buyer && !buyer.buyer?
      errors.add(:buyer, 'は一般ユーザーである必要があります')
    end
    
    if agent && !agent.agent?
      errors.add(:agent, 'は不動産業者である必要があります')
    end
  end
end
