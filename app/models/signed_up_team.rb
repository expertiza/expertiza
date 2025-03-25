class SignedUpTeam < ApplicationRecord
  belongs_to :topic, class_name: 'SignUpTopic'
  belongs_to :team, class_name: 'Team'

  # Validations
  validates :topic_id, :team_id, presence: true

  # Scopes for efficient querying
  scope :by_team_id, ->(team_id) { where(team_id: team_id) }
  scope :waitlisted, -> { where(is_waitlisted: true) }
  scope :confirmed, -> { where(is_waitlisted: false) }
  scope :by_topic_id, ->(topic_id) { where(topic_id: topic_id) }
  scope :by_assignment_id, ->(assignment_id) { joins(:topic).where(sign_up_topics: { assignment_id: assignment_id }) }

  # Find team participants for an assignment
  def self.find_team_participants(assignment_id)
    TeamsParticipant.joins('INNER JOIN teams ON teams_participants.team_id = teams.id')
                    .where('teams.parent_id = ?', assignment_id)
                    .includes(:participant, :team)
  end

  # Find team for a user in an assignment
  def self.find_team_for_user(assignment_id, user_id)
    participant = AssignmentParticipant.find_by(user_id: user_id, parent_id: assignment_id)
    return nil unless participant
    TeamsParticipant.find_by(participant_id: participant.id)&.team
  end

  # Find signup topics for a team
  def self.find_team_signup_topics(assignment_id, team_id)
    joins(:topic)
      .select('sign_up_topics.id as topic_id, sign_up_topics.topic_name, signed_up_teams.is_waitlisted, signed_up_teams.preference_priority_number')
      .where('sign_up_topics.assignment_id = ? AND signed_up_teams.team_id = ?', assignment_id, team_id)
  end

  # Release topics selected by a team for an assignment
  def self.release_topics_selected_by_team_for_assignment(team_id, assignment_id)
    transaction do
      old_teams_signups = where(team_id: team_id)
      return if old_teams_signups.empty?

      old_teams_signups.each do |signup|
        if !signup.is_waitlisted
          first_waitlisted = find_by(topic_id: signup.topic_id, is_waitlisted: true)
          Invitation.remove_waitlists_for_team(signup.topic_id, assignment_id) if first_waitlisted
        end
        signup.destroy
      end
    end
  end

  # Get topic ID for a team
  def self.topic_id_by_team_id(team_id)
    confirmed.by_team_id(team_id).first&.topic_id
  end

  # Remove a specific signup record
  def self.drop_signup_record(topic_id, team_id)
    find_by(topic_id: topic_id, team_id: team_id)&.destroy
  end

  # Remove all waitlisted records for a team
  def self.drop_off_waitlists(team_id)
    waitlisted.by_team_id(team_id).destroy_all
  end

  # Check if a team is waitlisted for a topic
  def waitlisted?
    is_waitlisted
  end

  # Check if a team is confirmed for a topic
  def confirmed?
    !is_waitlisted
  end

  # class methods
  def self.topic_id(assignment_id, user_id)
    participant = AssignmentParticipant.find_by(user_id: user_id, parent_id: assignment_id)
    return nil unless participant
    
    team_participant = TeamsParticipant.find_by(participant_id: participant.id)
    return nil unless team_participant
    
    signed_up_team = where(team_id: team_participant.team_id).first
    signed_up_team&.topic_id
  end
end

