class AdminController < ApplicationController
  # 管理者認証を必須とする
  before_action :authenticate_user!
  before_action :ensure_admin!
  before_action :verify_admin_password!

  # 管理画面専用のレイアウトを使用
  layout 'admin'

  private

  # 管理者権限をチェック
  def ensure_admin!
    unless current_user&.admin?
      redirect_to root_path, alert: '管理者権限が必要です。'
    end
  end

  # 管理画面へのパスワード認証
  def verify_admin_password!
    # セッションに管理画面パスワードが保存されているかチェック
    return if session[:admin_verified]

    # 管理画面パスワード入力ページにリダイレクト
    unless params[:controller] == 'admin/auth' && params[:action] == 'verify'
      redirect_to admin_auth_path
    end
  end

  # 管理画面セッションをクリア
  def clear_admin_session!
    session.delete(:admin_verified)
  end
end