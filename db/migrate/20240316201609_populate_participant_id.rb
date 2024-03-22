class PopulateParticipantId < ActiveRecord::Migration[5.1]
    def up
      # Assuming 'TeamsParticipant', 'Team', and 'Participant' are your model names
      # Iterate over each teams_participants record
      TeamsParticipant.find_each do |team_participant|
        # Find the team with the given team_id
        team = Team.find_by(id: team_participant.team_id)
        # Now, find the participant using the team's assignment_id and the user_id from the team_participant record
        participant = Participant.find_by(assignment_id: team.assignment_id, user_id: team_participant.user_id)
  
        # If a corresponding participant was found, update the teams_participant record
        if participant.present?
          team_participant.update(participant_id: participant.id)
        else
          # If no matching participant is found, you might want to handle it depending on your needs
          # For example, you could log it, raise an exception, or leave the participant_id as nil
          puts "No matching participant found for TeamsParticipant with user_id #{team_participant.user_id}"
        end
      end
    end
  
    def down
      # You can also define a way to revert this migration, if necessary
      # This might simply involve setting all participant_id values to nil
      TeamsParticipant.update_all(participant_id: nil)
    end
  end