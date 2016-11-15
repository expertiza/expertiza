class AddDutyBasedReviewStrategyToAssignments < ActiveRecord::Migration
  def change
    add_column :assignments, :duty_based, :integer
    add_column :assignments, :allow_duty_share, :integer
    add_column :assignments, :duty_names, :string
  end
end
