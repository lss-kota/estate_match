class Property < ApplicationRecord
  belongs_to :user

  # Active Storageアソシエーション
  has_many_attached :images          # 複数の物件画像
  has_one_attached :floor_plan       # 間取り図（1枚）

  # タグ関連アソシエーション
  has_many :property_tags, dependent: :destroy
  has_many :tags, through: :property_tags
  
  # お気に入り関連アソシエーション
  has_many :favorites, dependent: :destroy
  has_many :favorited_by_users, through: :favorites, source: :user

  # 物件種別の定義
  enum :property_type, {
    house: 0,        # 戸建て
    mansion: 1,      # マンション
    land: 2,         # 土地
    apartment: 3     # アパート
  }

  # 募集ステータスの定義
  enum :status, {
    active: 0,       # 募集中
    completed: 1,    # 成約済み
    paused: 2        # 一時停止
  }

  # スコープ
  scope :active, -> { where(status: :active) }

  # バリデーション
  validates :title, presence: true, length: { maximum: 100 }
  validates :description, presence: true, length: { maximum: 2000 }
  validates :prefecture, presence: true
  validates :city, presence: true
  validates :address, presence: true
  validates :property_type, presence: true
  validates :status, presence: true
  
  # 価格に関するバリデーション（売買価格か賃料のどちらか必須）
  validate :price_presence
  
  # 数値の正数チェック
  validates :sale_price, numericality: { greater_than: 0, allow_nil: true }
  validates :rental_price, numericality: { greater_than: 0, allow_nil: true }
  validates :deposit, numericality: { greater_than_or_equal_to: 0, allow_nil: true }
  validates :key_money, numericality: { greater_than_or_equal_to: 0, allow_nil: true }
  validates :management_fee, numericality: { greater_than_or_equal_to: 0, allow_nil: true }
  validates :station_distance, numericality: { greater_than: 0, allow_nil: true }
  validates :building_area, numericality: { greater_than: 0, allow_nil: true }
  validates :land_area, numericality: { greater_than: 0, allow_nil: true }
  validates :construction_year, numericality: { 
    greater_than: 1900, 
    less_than_or_equal_to: -> { Date.current.year },
    allow_nil: true 
  }

  # 物件の取引種別を判定するメソッド
  def for_sale?
    sale_price.present?
  end

  def for_rent?
    rental_price.present?
  end

  def for_both?
    for_sale? && for_rent?
  end

  # 取引種別を取得（仮想属性）
  def transaction_type
    if for_both?
      'both'
    elsif for_sale?
      'sale'
    elsif for_rent?
      'rent'
    else
      nil
    end
  end

  # 取引種別を設定（仮想属性）
  def transaction_type=(value)
    case value
    when 'sale'
      # 売買のみ：賃貸価格をクリア
      self.rental_price = nil
      self.deposit = nil
      self.key_money = nil
      self.management_fee = nil
    when 'rent'
      # 賃貸のみ：売買価格をクリア
      self.sale_price = nil
    when 'both'
      # 両方：何もクリアしない
    end
  end

  # 表示用の価格フォーマット
  def formatted_sale_price
    return nil unless sale_price
    "#{sale_price}万円"
  end

  def formatted_rental_price
    return nil unless rental_price
    "#{rental_price}円/月"
  end
  
  # お気に入り関連のヘルパーメソッド
  def favorited_by?(user)
    return false unless user
    favorites.exists?(user: user)
  end
  
  def favorites_count
    favorites.count
  end

  private

  def price_presence
    unless sale_price.present? || rental_price.present?
      errors.add(:base, '売買価格または賃料のどちらか一つは必須です')
    end
  end
end
