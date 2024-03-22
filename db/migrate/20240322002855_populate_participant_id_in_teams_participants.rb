class PopulateParticipantIdInTeamsParticipants < ActiveRecord::Migration[5.1]
  def change
    TeamsParticipant.find_each do |tp|
      next unless Team.exists?(tp.team_id)
      
      team = Team.find(tp.team_id)
      # Assuming `parent_id` in `teams` refers to an `assignment_id`
      assignment_id = team.parent_id

      # Find a participant with the same `user_id` and `parent_id` (assignment)
      participant = Participant.find_by(user_id: tp.user_id, parent_id: assignment_id)

      if participant
        # Update the teams_participants record with the found participant's ID
        tp.update_column(:participant_id, participant.id)
      else
        # Handle cases where no participant is found (e.g., log or take corrective action)
        puts "No participant found for TeamsParticipant with ID: #{tp.id}"
      end
    end
  end

  def down
    # Optionally, clear the participant_id column if rolling back
    TeamsParticipant.update_all(participant_id: nil)
  end
end
