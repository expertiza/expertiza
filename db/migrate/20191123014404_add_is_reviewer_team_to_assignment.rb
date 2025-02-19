class AddIsReviewerTeamToAssignment < ActiveRecord::Migration[4.2]
  def change
    add_column :assignments, :team_reviewing_enabled, :boolean, default: false
  end
end
