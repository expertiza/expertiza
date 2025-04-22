# db/migrate/20240320000002_add_participant_id_to_teams_participants.rb
class AddParticipantIdToTeamsParticipants < ActiveRecord::Migration[5.1]
    disable_ddl_transaction!  # if you have a large table
  
    def up
      unless column_exists?(:teams_participants, :participant_id)
        add_column :teams_participants, :participant_id, :integer
        add_index  :teams_participants, :participant_id, algorithm: :concurrently
  
        # back‐fill: for each row, find the Participant whose user_id = old user_id
        TeamsParticipant.reset_column_information
        TeamsParticipant.find_each do |tp|
          team = Team.find(tp.team_id)
          part = Participant.find_by(user_id: tp.user_id, parent_id: team.parent_id)
          tp.update_column(:participant_id, part.id) if part
        end
  
        change_column_null :teams_participants, :participant_id, false
      end
    end
  
    def down
      if column_exists?(:teams_participants, :participant_id)
        remove_column :teams_participants, :participant_id
      end
    end
  end
  