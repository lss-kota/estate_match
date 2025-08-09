class DashboardController < ApplicationController
  # ユーザーのマイページ（ダッシュボード）の表示
  # ログイン必須（ApplicationControllerで設定済み）
  def index
    # current_userはDeviseによって自動的に設定される
    # ログイン中のユーザー情報を取得してビューで使用
    # - ユーザー名、メールアドレス
    # - ユーザータイプ（buyer/owner）
    # - 二段階認証の状態
    # - 各種統計情報（お気に入り、登録物件、メッセージ等）
  end
end
