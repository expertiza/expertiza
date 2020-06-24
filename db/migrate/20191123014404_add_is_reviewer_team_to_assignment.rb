class AddIsReviewerTeamToAssignment < ActiveRecord::Migration
  def change
    add_column :assignments, :reviewer_is_team, :boolean
  end
end
