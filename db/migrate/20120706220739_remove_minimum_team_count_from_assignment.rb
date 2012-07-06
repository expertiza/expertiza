class RemoveMinimumTeamCountFromAssignment < ActiveRecord::Migration
  def self.up
    remove_column :assignments, :minimum_team_count
  end

  def self.down
    add_column :assignments, :minimum_team_count, :integer
  end
end
