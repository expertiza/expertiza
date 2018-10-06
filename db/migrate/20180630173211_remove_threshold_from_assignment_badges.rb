class RemoveThresholdFromAssignmentBadges < ActiveRecord::Migration
  def change
    remove_column :assignment_badges, :threshold, :integer
  end
end
