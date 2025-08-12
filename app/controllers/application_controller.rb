class ApplicationController < ActionController::Base
  # モダンブラウザのみ許可（webp画像、web push等をサポート）
  allow_browser versions: :modern

  # 全てのアクションでユーザー認証を必須とする
  # 個別のコントローラーで skip_before_action で除外可能
  before_action :authenticate_user!
  
  # Active Storage URL optionsを設定
  before_action :set_active_storage_current_attributes
  
  # Deviseコントローラーの場合のみ、追加パラメータの許可設定を実行
  before_action :configure_permitted_parameters, if: :devise_controller?

  private

  # Active Storage用のURL optionsを設定
  def set_active_storage_current_attributes
    ActiveStorage::Current.url_options = { 
      host: request.base_url
    }
  end

  protected

  # Deviseのストロングパラメータ設定
  # デフォルトのemail, passwordに加えて、name, user_typeを許可
  def configure_permitted_parameters
    # ユーザー登録時に許可するパラメータ
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :user_type])
    # アカウント更新時に許可するパラメータ
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :user_type])
  end

  # ログイン成功後のリダイレクト先を指定
  # @param resource [User] ログインしたユーザー
  # @return [String] リダイレクト先のパス
  def after_sign_in_path_for(resource)
    dashboard_path  # マイページ（ダッシュボード）にリダイレクト
  end

  # ログアウト後のリダイレクト先を指定
  # @param resource [User] ログアウトしたユーザー
  # @return [String] リダイレクト先のパス
  def after_sign_out_path_for(resource_or_scope)
    root_path  # ランディングページにリダイレクト
  end
end
