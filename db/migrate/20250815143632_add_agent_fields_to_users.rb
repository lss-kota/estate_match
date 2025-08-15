class AddAgentFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_reference :users, :membership_plan, null: true, foreign_key: true
    add_column :users, :company_name, :string
    add_column :users, :license_number, :string
    add_column :users, :monthly_message_count, :integer, default: 0
    add_column :users, :message_count_reset_at, :datetime

    add_index :users, :license_number, unique: true
    # membership_plan_idのインデックスはadd_referenceで自動作成されるため削除
  end
end
