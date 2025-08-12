class Favorite < ApplicationRecord
  belongs_to :user
  belongs_to :property
  
  # 同じユーザーが同じ物件を重複してお気に入りできないようにユニーク制約
  validates :user_id, uniqueness: { scope: :property_id }
end
