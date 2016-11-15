class AddDutyBasedReviewStrategyToAssignments < ActiveRecord::Migration
  def change
    add_column :assignments, :duty_based, :boolean
    add_column :assignments, :allow_duty_share, :boolean
    add_column :assignments, :duty_names, :string
  end
end
