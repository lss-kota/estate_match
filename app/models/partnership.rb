class Partnership < ApplicationRecord
  # アソシエーション
  belongs_to :agent, class_name: 'User'
  belongs_to :owner, class_name: 'User'

  # ステータスの定義
  enum :status, {
    pending: 0,    # 申請中
    active: 1,     # 有効
    inactive: 2,   # 無効
    terminated: 3  # 終了
  }

  # バリデーション
  validates :agent_id, presence: true
  validates :owner_id, presence: true
  validates :commission_rate, presence: true, 
            numericality: { greater_than: 0, less_than_or_equal_to: 100 }
  validates :agent_id, uniqueness: { scope: :owner_id }

  # カスタムバリデーション
  validate :validate_user_types
  validate :validate_dates

  # スコープ
  scope :active, -> { where(status: :active) }
  scope :pending, -> { where(status: :pending) }
  scope :for_agent, ->(agent_id) { where(agent_id: agent_id) }
  scope :for_owner, ->(owner_id) { where(owner_id: owner_id) }

  # メソッド
  def activate!
    update!(status: :active, started_at: Time.current)
  end

  def terminate!
    update!(status: :terminated, ended_at: Time.current)
  end

  def duration_days
    return 0 unless started_at
    end_date = ended_at || Time.current
    ((end_date - started_at) / 1.day).round
  end

  def formatted_commission_rate
    "#{commission_rate}%"
  end

  private

  def validate_user_types
    if agent && !agent.agent?
      errors.add(:agent, 'は不動産業者である必要があります')
    end
    
    if owner && !owner.owner?
      errors.add(:owner, 'はオーナーである必要があります')
    end
  end

  def validate_dates
    if started_at && ended_at && started_at > ended_at
      errors.add(:ended_at, 'は開始日より後である必要があります')
    end
  end
end
