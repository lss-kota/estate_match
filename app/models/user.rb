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
  # 0: buyer（購入希望者）, 1: owner（物件オーナー）
  enum :user_type, { buyer: 0, owner: 1 }

  # 二段階認証機能（ROTP gem使用）
  # encrypted: true で秘密鍵を暗号化して保存
  # 一時的にコメントアウト（gemの問題を解決後に有効化）
  # has_one_time_password(encrypted: true)

  # バリデーション設定
  validates :name, presence: true # 名前は必須

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

  private

  # OTP用の秘密鍵を生成
  # 既に秘密鍵がある場合は生成しない
  def generate_otp_secret_key
    # self.otp_secret_key = User.generate_random_base32 if otp_secret_key.blank?
  end
end
