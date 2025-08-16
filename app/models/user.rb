class User < ApplicationRecord
  # Deviseの基本機能を有効化
  # :database_authenticatable - メールアドレス＆パスワードでのログイン
  # :registerable - ユーザー登録機能
  # :recoverable - パスワードリセット機能
  # :rememberable - ログイン状態の記憶機能
  # :validatable - メール・パスワードのバリデーション
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # ユーザータイプの列挙型定義
  # 0: buyer（購入希望者）, 1: owner（物件オーナー）, 2: agent（不動産業者）, 99: admin（管理者）
  enum :user_type, { buyer: 0, owner: 1, agent: 2, admin: 99 }

  # 二段階認証機能（ROTP gem使用）
  # encrypted: true で秘密鍵を暗号化して保存
  # 一時的にコメントアウト（gemの問題を解決後に有効化）
  # has_one_time_password(encrypted: true)

  # 関連付け
  has_many :properties, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :favorite_properties, through: :favorites, source: :property
  
  # メッセージ機能関連
  has_many :sent_messages, class_name: 'Message', foreign_key: 'sender_id', dependent: :destroy
  has_many :buyer_conversations, class_name: 'Conversation', foreign_key: 'buyer_id', dependent: :destroy
  has_many :owner_conversations, class_name: 'Conversation', foreign_key: 'owner_id', dependent: :destroy

  # 不動産業者関連のアソシエーション
  belongs_to :membership_plan, optional: true
  has_many :agent_partnerships, class_name: 'Partnership', foreign_key: 'agent_id', dependent: :destroy
  has_many :owner_partnerships, class_name: 'Partnership', foreign_key: 'owner_id', dependent: :destroy
  has_many :partner_owners, through: :agent_partnerships, source: :owner
  has_many :partner_agents, through: :owner_partnerships, source: :agent
  
  # 問い合わせ関連
  has_many :buyer_inquiries, class_name: 'Inquiry', foreign_key: 'buyer_id', dependent: :destroy
  has_many :agent_inquiries, class_name: 'Inquiry', foreign_key: 'agent_id', dependent: :destroy

  # バリデーション設定
  validates :name, presence: true # 名前は必須
  validates :user_type, presence: true # ユーザータイプは必須
  
  # 不動産業者の場合の追加バリデーション
  validates :company_name, presence: true, if: :agent?
  validates :license_number, presence: true, uniqueness: true, if: :agent?
  validates :membership_plan, presence: true, if: :agent?

  # ユーザー作成時に二段階認証が有効な場合、OTP秘密鍵を自動生成
  # before_create :generate_otp_secret_key, if: :otp_required_for_login?

  # 二段階認証用QRコードの生成
  # Google Authenticator等のアプリで読み取れるQRコードを生成
  # @return [RQRCode::QRCode] QRコードオブジェクト
  def otp_qr_code
    # 一時的に無効化
    # issuer = "Estate Match"  # 発行者名
    # label = "#{issuer}:#{email}"  # ラベル（アプリ上での表示名）
    # 
    # # OTP用URIを生成してQRコード化
    # RQRCode::QRCode.new(otp_provisioning_uri(label, issuer: issuer))
    nil
  end

  # 二段階認証を有効化
  # OTP必須フラグをtrueにして秘密鍵を生成・保存
  def enable_otp!
    self.otp_required_for_login = true
    # generate_otp_secret_key
    save!
  end

  # 二段階認証を無効化
  # OTP必須フラグをfalseにして秘密鍵をクリア
  def disable_otp!
    self.otp_required_for_login = false
    self.otp_secret_key = nil
    save!
  end

  # メッセージ機能用ヘルパーメソッド
  def conversations
    Conversation.for_user(self).recent
  end

  def unread_messages_count
    conversations.sum { |conv| conv.unread_count_for(self) }
  end

  def can_message_about_property?(property)
    return false if property.user == self # 自分の物件にはメッセージ不可
    return buyer? || owner? # 購入者またはオーナーのみ
  end

  # 不動産業者関連のメソッド - 新しい権限システム対応
  def can_message_owner?(owner)
    return false unless agent?
    return false unless owner.owner?
    return false if monthly_message_limit_exceeded?
    
    # パートナーシップがある場合は常にメッセージ可能
    return true if has_partnership_with?(owner)
    
    # 月間物件制限内かチェック
    current_month_contacted_properties < monthly_property_limit
  end
  
  # 新しい会話を開始できるかチェック
  def can_start_new_conversation?
    return false unless agent? && membership_plan
    
    monthly_property_count < membership_plan.monthly_property_limit
  end
  
  # 月間メッセージした物件数
  def monthly_property_count
    return 0 unless agent?
    
    # 今月作成されたagent_ownerタイプの会話から、ユニークな物件数を取得
    Conversation.where(conversation_type: :agent_owner)
      .where(agent: self)
      .where(created_at: Time.current.beginning_of_month..Time.current.end_of_month)
      .distinct
      .count(:property_id)
  end

  def has_partnership_with?(user)
    case user.user_type
    when 'owner'
      agent_partnerships.active.exists?(owner: user)
    when 'agent'
      owner_partnerships.active.exists?(agent: user)
    else
      false
    end
  end

  def monthly_property_limit
    membership_plan&.monthly_property_limit || 0
  end

  def current_month_contacted_properties
    monthly_property_count || 0
  end

  def monthly_property_limit_exceeded?
    return false unless agent?
    current_month_contacted_properties >= monthly_property_limit
  end

  def reset_monthly_message_count!
    return unless agent?
    update!(
      monthly_message_count: 0,
      message_count_reset_at: Time.current
    )
  end

  def increment_monthly_message_count!
    return unless agent?
    increment!(:monthly_message_count)
  end

  def active_partnerships
    case user_type
    when 'agent'
      agent_partnerships.active.includes(:owner)
    when 'owner'
      owner_partnerships.active.includes(:agent)
    else
      Partnership.none
    end
  end

  # 未読メッセージ件数を取得
  def unread_messages_count
    case user_type
    when 'agent'
      # 不動産業者の場合：agent_ownerタイプの会話での未読メッセージ
      Message.joins(:conversation)
             .where(conversations: { agent_id: id, conversation_type: 'agent_owner' })
             .where.not(sender_id: id)
             .where(read_at: nil)
             .count
    when 'owner'
      # オーナーの場合：自分がオーナーの会話での未読メッセージ
      Message.joins(:conversation)
             .where(conversations: { owner_id: id })
             .where.not(sender_id: id)
             .where(read_at: nil)
             .count
    when 'buyer'
      # 購入希望者の場合：自分がbuyerの会話での未読メッセージ
      Message.joins(:conversation)
             .where(conversations: { buyer_id: id })
             .where.not(sender_id: id)
             .where(read_at: nil)
             .count
    else
      0
    end
  end

  def pending_partnership_requests
    case user_type
    when 'agent'
      agent_partnerships.pending.includes(:owner)
    when 'owner'
      owner_partnerships.pending.includes(:agent)
    else
      Partnership.none
    end
  end

  def display_name
    case user_type
    when 'agent'
      company_name.present? ? "#{company_name}（#{name}）" : name
    else
      name
    end
  end

  private

  # OTP用の秘密鍵を生成
  # 既に秘密鍵がある場合は生成しない
  def generate_otp_secret_key
    # self.otp_secret_key = User.generate_random_base32 if otp_secret_key.blank?
  end
end
