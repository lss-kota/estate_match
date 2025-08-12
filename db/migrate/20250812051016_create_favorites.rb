class CreateFavorites < ActiveRecord::Migration[8.0]
  def change
    create_table :favorites do |t|
      t.references :user, null: false, foreign_key: true
      t.references :property, null: false, foreign_key: true

      t.timestamps
    end
    
    # 同じユーザーが同じ物件を重複してお気に入りできないようにユニーク制約を追加
    add_index :favorites, [:user_id, :property_id], unique: true
  end
end
