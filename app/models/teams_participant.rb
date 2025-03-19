class TeamsParticipant < ApplicationRecord
    belongs_to :team
    belongs_to :participant
    belongs_to :duty, optional: true
  
    validates :team_id, presence: true
    validates :participant_id, presence: true
    validates :participant_id, uniqueness: { scope: :team_id, message: "is already a member of this team" }
  
    # Class method to find team_id for a participant in an assignment
    def self.team_id(assignment_id, participant_id)
      team = Team.find_by(parent_id: assignment_id)
      return nil unless team
  
      teams_participant = find_by(team_id: team.id, participant_id: participant_id)
      teams_participant&.team_id
    end
  
    # Class method to check if a team is empty
    def self.team_empty?(team_id)
      where(team_id: team_id).empty?
    end
  
    # Class method to add a member to an invited team
    def self.add_member_to_invited_team(inviter_id, invitee_id, assignment_id)
      team = Team.find_by(parent_id: assignment_id)
      return false unless team
  
      inviter_participant = Participant.find_by(user_id: inviter_id, parent_id: assignment_id)
      invitee_participant = Participant.find_by(user_id: invitee_id, parent_id: assignment_id)
      
      return false unless inviter_participant && invitee_participant
  
      # Check if invitee is already on a team
      existing_team = team_id(assignment_id, invitee_participant.id)
      return false if existing_team
  
      # Add invitee to the team
      create(team_id: team.id, participant_id: invitee_participant.id)
    end
  end 