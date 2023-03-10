class PopulateParticipantId < ActiveRecord::Migration[5.1]
  def change
    teams_participants = TeamsParticipant.all
    teams_participants.each do |team_participant|
      unless team_participant.team_id.nil?
        team = Team.find(team_participant.team_id)
        unless team.nil?
          participant = Participant.find_by(user_id: team_participant["user_id"], parent_id: team["parent_id"])
          unless participant.nil?
            team_participant.participant_id = participant.id
            team_participant.save
          end
        end
      end
    end
  end
end
