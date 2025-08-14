class LegalController < ApplicationController
  # 法的文書は未ログインユーザーでも閲覧可能
  skip_before_action :authenticate_user!
  
  # 利用規約
  def terms
  end
  
  # プライバシーポリシー
  def privacy
  end
  
  # 運営会社情報
  def company
  end
  
  # 特定商取引法に基づく表示
  def tokutei
  end
end