class RenameTeamCountToMaxTeamSize < ActiveRecord::Migration[4.2]
  def self.up
    rename_column :assignments, :team_count, :max_team_size
  end

  def self.down
    rename_column :assignments, :max_team_size, :team_count
  end
end
