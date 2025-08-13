class CreateConversations < ActiveRecord::Migration[8.0]
  def change
    create_table :conversations do |t|
      t.references :property, null: false, foreign_key: true
      t.references :buyer, null: false, foreign_key: { to_table: :users }
      t.references :owner, null: false, foreign_key: { to_table: :users }
      t.datetime :last_message_at

      t.timestamps
    end

    # 同じ物件に対して同じ購入者・オーナーペアの会話は1つだけ
    add_index :conversations, [:property_id, :buyer_id, :owner_id], unique: true
  end
end
