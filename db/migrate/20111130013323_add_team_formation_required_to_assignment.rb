class AddTeamFormationRequiredToAssignment < ActiveRecord::Migration
  def self.up
    add_column :assignments, :team_formation_required, :boolean
  end

  def self.down
    remove_column :assignments, :team_formation_required
  end
end
