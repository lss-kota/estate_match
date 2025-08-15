class CreateMembershipPlans < ActiveRecord::Migration[8.0]
  def change
    create_table :membership_plans do |t|
      t.string :name, null: false
      t.integer :monthly_owner_limit, null: false, default: 0
      t.integer :monthly_price, null: false, default: 0
      t.text :features
      t.boolean :active, null: false, default: true
      t.integer :sort_order, default: 0

      t.timestamps
    end

    add_index :membership_plans, :active
    add_index :membership_plans, :sort_order
  end
end
