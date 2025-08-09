class PagesController < ApplicationController
  # indexアクション（ランディングページ）は認証不要
  # 未登録・未ログインユーザーでもアクセス可能にする
  skip_before_action :authenticate_user!, only: [:index]
  
  # ランディングページの表示
  # Estate Matchのトップページを表示する
  def index
  end
end
