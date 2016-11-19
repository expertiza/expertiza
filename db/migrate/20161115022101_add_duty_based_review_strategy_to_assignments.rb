class AddDutyBasedReviewStrategyToAssignments < ActiveRecord::Migration
  def change
    add_column :assignments, :duty_based, :boolean, :default => false
    add_column :assignments, :allow_duty_share, :boolean, :default => false
    add_column :assignments, :duty_names, :string
  end
end
