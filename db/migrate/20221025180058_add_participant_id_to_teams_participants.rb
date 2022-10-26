class AddParticipantIdToTeamsParticipants < ActiveRecord::Migration[5.1]
  def change
    add_column :teams_participants, :participant_id, :integer
    add_reference :teams_participants, :participants, index: true, foreign_key: true
    # add_foreign_key :teams_participants, :participants, column: :participant_id
    
    teams_participants = TeamsParticipant.all
    teams_participants.each do |team_participant|
      if !team_participant.team_id.nil?
        team = Team.find(team_participant.team_id)
        if !team.nil?
          participant = Participant.find_by(user_id: team_participant["user_id"], parent_id: team["parent_id"])
          if !participant.nil?
            team_participant.participant_id = participant["id"]
            team_participant.save
          end
        end
      end
      next unless team_participant.participant_id
    end
  end
end
