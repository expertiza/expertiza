class RemoveTeamFormationRequiredFromAssignment < ActiveRecord::Migration
  def self.up
    remove_column :assignments, :team_formation_required
  end

  def self.down
    add_column :assignments, :team_formation_required, :boolean
  end
end
