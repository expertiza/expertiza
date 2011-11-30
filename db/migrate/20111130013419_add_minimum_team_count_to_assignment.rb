class AddMinimumTeamCountToAssignment < ActiveRecord::Migration
  def self.up
    add_column :assignments, :minimum_team_count, :integer
  end

  def self.down
    remove_column :assignments, :minimum_team_count
  end
end
