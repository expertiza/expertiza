class AddIsReviewerTeamToAssignment < ActiveRecord::Migration[4.2]
  def change
    add_column :assignments, :reviewer_is_team, :boolean
  end
end
