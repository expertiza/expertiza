class AddParticipantIdAndPopulate < ActiveRecord::Migration[5.1]

  def up
    # add_column :teams_users, :participant_id, :integer, limit: 4, index: true
    # add_foreign_key :teams_users, :participants
    # firstly, fetch all TeamsUser rows
    teams_participants = TeamsUser.all
    # for each TeamsUser row
    teams_participants.each do |team_participant|
      # if team_id is not nil
      unless team_participant.team_id.nil?
        # fetch team using team_id
        team = Team.find(team_participant.team_id)
        # if team is not nil
        unless team.nil?
          # fetch the participant using team's user_id and parent_id (which is mapped in Participant table)
          participant = Participant.find_by(user_id: team_participant["user_id"], parent_id: team["parent_id"])
          # if participant is not found for such a user and it's team, we will have to create a participant first
          if participant.nil?
            # create the participant using the user_id and parent_id
            participant = Participant.create(user_id: team_participant["user_id"], parent_id: team["parent_id"])
            participant.save
          end
          # assign the participant_id to the TeamsUser row
          # here, we know for sure that participant_id is defined as we first fetch it
          # and if it's not found, we create it
          team_participant.participant_id = participant.id
          team_participant.save
        end
      end
    end
  end

  def down
    # remove foreign key constraint of participant_id added to the teams_users table
    # remove the column participant_id added to the teams_users table
    remove_foreign_key :teams_users, :participant_id
    remove_column :teams_users, :participant_id
  end
end
