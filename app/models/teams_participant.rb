class TeamsParticipant < ApplicationRecord
  belongs_to :team
  belongs_to :participant
  belongs_to :duty, optional: true

  validates :team_id, presence: true
  validates :participant_id, presence: true
  validates :participant_id, uniqueness: { scope: :team_id, message: "is already a member of this team" }

  # Class method to find team_id for a participant in an assignment
  def self.team_id(assignment_id, user_id)
    participant = AssignmentParticipant.find_by(user_id: user_id, parent_id: assignment_id)
    return nil unless participant
    find_by(participant_id: participant.id)&.team_id
  end

  # Class method to check if a team is empty
  def self.team_empty?(team_id)
    where(team_id: team_id).empty?
  end

  # Class method to add a member to an invited team
  # This method handles adding a participant to a team they've been invited to join
  # Returns true if successful, false otherwise
  def self.add_member_to_invited_team(inviter_user_id, invited_user_id, assignment_id)
    # Find both participants in a single query
    participants = AssignmentParticipant.where(
      user_id: [inviter_user_id, invited_user_id],
      parent_id: assignment_id
    ).index_by(&:user_id)

    # Return false if either participant is missing
    return false unless participants[inviter_user_id] && participants[invited_user_id]

    # Find the inviter's team in a single query
    inviter_team = find_by(participant_id: participants[inviter_user_id].id)&.team
    return false unless inviter_team

    # Check if team is full
    return false if inviter_team.full?

    # Create the team participant record
    begin
      create!(
        team_id: inviter_team.id,
        participant_id: participants[invited_user_id].id
      )
      true
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error "Failed to add member to team: #{e.message}"
      false
    end
  end

  def self.get_team_members(team_id)
    where(team_id: team_id).map(&:participant).map(&:user)
  end

  def self.get_teams_for_user(user_id)
    participant = AssignmentParticipant.find_by(user_id: user_id)
    return [] unless participant
    where(participant_id: participant.id).map(&:team)
  end
end 