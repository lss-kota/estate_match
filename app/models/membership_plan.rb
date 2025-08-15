class MembershipPlan < ApplicationRecord
  # アソシエーション
  has_many :users, dependent: :nullify

  # バリデーション
  validates :name, presence: true, length: { maximum: 100 }
  validates :monthly_property_limit, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :monthly_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :sort_order, numericality: { greater_than_or_equal_to: 0 }

  # スコープ
  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(:sort_order, :id) }

  # features をJSONとして扱う
  serialize :features, coder: JSON

  # 表示用メソッド
  def formatted_price
    if monthly_price == 0
      "無料"
    else
      "#{monthly_price.to_s.gsub(/(\d)(?=(\d{3})+(?!\d))/, '\1,')}円/月"
    end
  end

  def features_list
    features.is_a?(Array) ? features : []
  end
end
