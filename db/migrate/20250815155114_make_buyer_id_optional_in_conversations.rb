class MakeBuyerIdOptionalInConversations < ActiveRecord::Migration[8.0]
  def change
    # buyer_idをnullableにして、agent-owner間の会話を可能にする
    change_column :conversations, :buyer_id, :bigint, null: true
  end
end
