class Admin::AuthController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin!

  # 管理画面パスワード入力ページ
  def verify
    if request.post?
      # 一時的にハードコードでパスワードチェック
      admin_password = Rails.application.credentials.admin_password || 'EstateSecure@Admin2024#Panel'
      
      if params[:password] == admin_password
        session[:admin_verified] = true
        redirect_to admin_dashboard_path, notice: '管理画面にアクセスしました。'
      else
        flash.now[:alert] = 'パスワードが正しくありません。'
      end
    end
  end

  # 管理画面からログアウト
  def logout
    session.delete(:admin_verified)
    redirect_to root_path, notice: '管理画面からログアウトしました。'
  end

  private

  def ensure_admin!
    unless current_user&.admin?
      redirect_to root_path, alert: '管理者権限が必要です。'
    end
  end
end