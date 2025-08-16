class AddMutualApprovalToPartnerships < ActiveRecord::Migration[8.0]
  def change
    add_column :partnerships, :agent_requested_at, :datetime
    add_column :partnerships, :owner_requested_at, :datetime
  end
end
