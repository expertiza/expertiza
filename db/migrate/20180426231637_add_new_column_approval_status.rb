class AddNewColumnApprovalStatus < ActiveRecord::Migration[4.2]
  def change
    add_column :awarded_badges, :approval_status, :integer
  end
end
