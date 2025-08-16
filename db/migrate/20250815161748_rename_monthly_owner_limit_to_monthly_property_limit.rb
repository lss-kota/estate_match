class RenameMonthlyOwnerLimitToMonthlyPropertyLimit < ActiveRecord::Migration[8.0]
  def change
    # カラム名を変更して、メッセージ制限の意味を「物件数制限」に明確化
    rename_column :membership_plans, :monthly_owner_limit, :monthly_property_limit
  end
end
