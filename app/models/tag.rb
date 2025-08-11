class Tag < ApplicationRecord
  has_many :property_tags, dependent: :destroy
  has_many :properties, through: :property_tags

  # バリデーション
  validates :name, presence: true, uniqueness: true, length: { maximum: 50 }
  validates :color, presence: true, format: { with: /\A#[0-9A-Fa-f]{6}\z/, message: "は#から始まる6桁の16進数で入力してください" }
  validates :category, presence: true, length: { maximum: 50 }
  validates :description, length: { maximum: 200 }

  # スコープ
  scope :by_category, ->(category) { where(category: category) }

  # カテゴリ一覧を取得
  def self.categories
    distinct.pluck(:category).compact
  end
end
