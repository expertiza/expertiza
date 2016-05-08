class AddIsReviewTeamToAssignment < ActiveRecord::Migration
  def change
	add_column :assignments, :reviewer_is_team, :boolean, default: false
  end
end
