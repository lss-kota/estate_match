class AddAgentFieldsToConversations < ActiveRecord::Migration[8.0]
  def change
    add_reference :conversations, :agent, null: true, foreign_key: { to_table: :users }
    add_reference :conversations, :inquiry, null: true, foreign_key: true
    add_column :conversations, :conversation_type, :integer, default: 0, null: false
    
    add_index :conversations, [:agent_id, :owner_id], name: 'index_conversations_on_agent_owner'
    add_index :conversations, [:conversation_type, :property_id]
  end
end
