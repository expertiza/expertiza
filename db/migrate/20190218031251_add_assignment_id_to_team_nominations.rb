class AddAssignmentIdToTeamNominations < ActiveRecord::Migration
  def change
    add_column :team_nominations, :assignment_id, :integer
  end
end
