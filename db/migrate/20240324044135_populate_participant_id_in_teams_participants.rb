class PopulateParticipantIdInTeamsParticipants < ActiveRecord::Migration[5.1]
  def up
    TeamsParticipant.find_each do |teams_participant|
      next unless Team.exists?(id: teams_participant.team_id)
      
      associated_team = Team.find(teams_participant.team_id)
      # Assuming `parent_id` in `teams` table refers to an `assignment_id`
      corresponding_assignment_id = associated_team.parent_id

      # Locate a participant with matching `user_id` and `parent_id` (assignment)
      matching_participant = Participant.find_by(user_id: teams_participant.user_id, parent_id: corresponding_assignment_id)

      if matching_participant
        # Populate the participant_id in teams_participants with the identified participant's ID
        teams_participant.update_column(:participant_id, matching_participant.id)
      else
        # Actions or logs for cases where no corresponding participant is found
        Rails.logger.info "No matching participant found for TeamsParticipant ID: #{teams_participant.id}"
      end
    end
  end

  def down
    # Reset the participant_id column for all records if the migration is rolled back
    TeamsParticipant.update_all(participant_id: nil)
  end
end
