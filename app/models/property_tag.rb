class PropertyTag < ApplicationRecord
  belongs_to :property
  belongs_to :tag

  # 重複防止
  validates :property_id, uniqueness: { scope: :tag_id }
end
