class CreatePartnerships < ActiveRecord::Migration[8.0]
  def change
    create_table :partnerships do |t|
      t.references :agent, null: false, foreign_key: { to_table: :users }
      t.references :owner, null: false, foreign_key: { to_table: :users }
      t.integer :status, null: false, default: 0
      t.datetime :started_at
      t.datetime :ended_at
      t.decimal :commission_rate, precision: 5, scale: 2
      t.text :terms

      t.timestamps
    end

    add_index :partnerships, [:agent_id, :owner_id], unique: true
    add_index :partnerships, :status
    add_index :partnerships, :started_at
  end
end
