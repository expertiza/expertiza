# db/migrate/20240320000004_add_fks_to_teams_participants.rb
class AddFksToTeamsParticipants < ActiveRecord::Migration[6.1]
    def change
      add_foreign_key :teams_participants, :teams
      add_foreign_key :teams_participants, :participants
    end
  end
  