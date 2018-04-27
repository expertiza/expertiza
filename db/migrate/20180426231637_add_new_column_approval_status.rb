class AddNewColumnApprovalStatus < ActiveRecord::Migration
  def change
    add_column :awarded_badges, :approval_status, :integer
  end
end
