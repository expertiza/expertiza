class DeleteUserIdFromTeamsParticipantsTable < ActiveRecord::Migration[5.1]
  def change
    if foreign_key_exists?(:teams_participants, :users)
      remove_foreign_key :teams_participants, :users
    end
    # remove_reference :teams_participants, :users
    remove_column :teams_participants, :user_id
  end
end
