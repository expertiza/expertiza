class AddReviewerIsTeamToAssignments < ActiveRecord::Migration
  def up
    add_column :assignments, :reviewer_is_team, :boolean, :default=>false
  end

  def down
    remove_column :assignments, :reviewer_is_team
  end
end
