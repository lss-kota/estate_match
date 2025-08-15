class CreateInquiries < ActiveRecord::Migration[8.0]
  def change
    create_table :inquiries do |t|
      t.references :property, null: false, foreign_key: true
      t.references :buyer, null: false, foreign_key: { to_table: :users }
      t.references :agent, null: false, foreign_key: { to_table: :users }
      t.integer :status, null: false, default: 0
      t.text :message
      t.datetime :contacted_at
      t.datetime :closed_at

      t.timestamps
    end

    add_index :inquiries, :status
    add_index :inquiries, :created_at
    add_index :inquiries, [:property_id, :buyer_id], unique: true
  end
end
