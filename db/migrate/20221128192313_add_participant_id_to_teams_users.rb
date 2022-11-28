class AddParticipantIdToTeamsUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :teams_users, :participant_id, :integer, index: true
    # add_reference :teams_users, :participants
    add_foreign_key :teams_users, :participants

    teams_users = TeamsUser.all
    teams_users.each do |teams_user|
      if !teams_user.team_id.nil?
        team = Team.find(teams_user.team_id)
        if !team.nil?
          participant = Participant.find_by(user_id: teams_user["user_id"], parent_id: team["parent_id"])
          if !participant.nil?
            teams_user.participant_id = participant["id"]
            teams_user.save
          end
        end
      end
      next unless teams_user.participant_id
    end
  end
end
