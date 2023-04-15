class AddParticipantIdAndPopulate < ActiveRecord::Migration[5.1]

  def up
    # add_column :teams_users, :participant_id, :integer, limit: 4, index: true
    # add_foreign_key :teams_users, :participants
    teams_participants = TeamsUser.all
    teams_participants.each do |team_participant|
      unless team_participant.team_id.nil?
        team = Team.find(team_participant.team_id)
        unless team.nil?
          participant = Participant.find_by(user_id: team_participant["user_id"], parent_id: team["parent_id"])
          if participant.nil?
            participant = Participant.create(user_id: team_participant["user_id"], parent_id: team["parent_id"])
            participant.save
          end
          team_participant.participant_id = participant.id
          team_participant.save
        end
      end
    end
  end

  def down
    remove_foreign_key :teams_users, :participant_id
    remove_column :teams_users, :participant_id
  end
end
