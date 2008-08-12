class UpdateAssignmentsForInvitations < ActiveRecord::Migration
  def self.up      
    add_column :assignments, :team_count, :integer, :null => false, :default => 0
    remove_column :assignments, :max_team_count
  end

  def self.down
    remove_column :assignments, :team_count
    add_column :assignments, :max_team_count, :boolean
  end
end
