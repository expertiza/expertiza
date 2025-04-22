# db/migrate/20240320000003_remove_user_id_from_teams_participants.rb
class RemoveUserIdFromTeamsParticipants < ActiveRecord::Migration[5.1]
  def up
    if column_exists?(:teams_participants, :user_id)
      # Remove any foreign key constraints first
      remove_foreign_key :teams_participants, :users if foreign_key_exists?(:teams_participants, :users)
      remove_column :teams_participants, :user_id, :integer
    end
  end

  def down
    unless column_exists?(:teams_participants, :user_id)
      add_column :teams_participants, :user_id, :integer
      add_foreign_key :teams_participants, :users
    end
  end
end
  