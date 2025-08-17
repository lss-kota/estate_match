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

  # 相互承認関連のメソッド
  def agent_request!
    update!(agent_requested_at: Time.current)
    check_mutual_approval!
  end

  def owner_request!
    update!(owner_requested_at: Time.current)
    check_mutual_approval!
  end

  def agent_requested?
    agent_requested_at.present?
  end

  def owner_requested?
    owner_requested_at.present?
  end

  def both_requested?
    agent_requested? && owner_requested?
  end
  
  # 管理画面用の承認状況メソッド
  def agent_approved?
    agent_requested_at.present?
  end
  
  def owner_approved?
    owner_requested_at.present?
  end
  
  def agent_approved_at
    agent_requested_at
  end
  
  def owner_approved_at
    owner_requested_at
  end

  def mutual_approval_status(current_user)
    return :not_applicable unless agent_owner_partnership?
    
    case current_user.user_type
    when 'agent'
      if both_requested? && active?
        :approved
      elsif agent_requested?
        :waiting_for_owner
      elsif owner_requested?
        :pending_approval
      else
        :not_requested
      end
    when 'owner'
      if both_requested? && active?
        :approved
      elsif owner_requested?
        :waiting_for_agent
      elsif agent_requested?
        :pending_approval
      else
        :not_requested
      end
    else
      :not_applicable
    end
  end

  def cancel_request!(user)
    case user.user_type
    when 'agent'
      update!(agent_requested_at: nil) if agent_requested?
    when 'owner'
      update!(owner_requested_at: nil) if owner_requested?
    end
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

  def check_mutual_approval!
    if both_requested? && pending?
      activate!
    end
  end

  def agent_owner_partnership?
    agent&.agent? && owner&.owner?
  end

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
