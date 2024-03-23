class RenameCreatorIdToTeamId < ActiveRecord::Migration[4.2]
  def self.up
    rename_column :signed_up_users, :creator_id, :team_id
  end

  def self.down
    rename_column :signed_up_users, :team_id, :creator_id
  end
end
