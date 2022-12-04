class SignedUpTeam < ApplicationRecord
  belongs_to :topic, class_name: 'SignUpTopic'
  belongs_to :team, class_name: 'Team'

  # the below has been added to make is consistent with the database schema
  validates :topic_id, :team_id, presence: true
  scope :by_team_id, ->(team_id) { where('team_id = ?', team_id) }

  def self.fill_participant_names(participants, ip_address = nil)
    i = 0
    participants.each do |participant|
      participant_names = User.joins('INNER JOIN teams_users ON users.id = teams_users.user_id')
                              .joins('INNER JOIN teams ON teams.id = teams_users.team_id')
                              .select('users.name as u_name, teams.name as team_name')
                              .where('teams.id = ?', participant.team_id)

      team_name_added = false
      names = '(missing team)'

      participant_names.each do |participant_name|
        if team_name_added
          names += User.find_by(name: participant_name.u_name).name(ip_address) + ' '
          participant.user_name_placeholder += User.find_by(name: participant_name.u_name).name(ip_address) + ' '
        else
          names = '[' + participant_name.team_name + '] ' + User.find_by(name: participant_name.u_name).name(ip_address) + ' '
          participant.team_name_placeholder = participant_name.team_name
          participant.user_name_placeholder = User.find_by(name: participant_name.u_name).name(ip_address) + ' '
          team_name_added = true
        end
      end
      participants[i].name = names
      i += 1
    end
  end

  def self.find_team_participants(assignment_id, ip_address = nil)
    @participants = SignedUpTeam.joins('INNER JOIN sign_up_topics ON signed_up_teams.topic_id = sign_up_topics.id')
                                .select('signed_up_teams.id as id, sign_up_topics.id as topic_id, sign_up_topics.topic_name as name,
                                  sign_up_topics.topic_name as team_name_placeholder, sign_up_topics.topic_name as user_name_placeholder,
                                  signed_up_teams.is_waitlisted as is_waitlisted, signed_up_teams.team_id as team_id')
                                .where('sign_up_topics.assignment_id = ?', assignment_id)
    fill_participant_names @participants, ip_address
    @participants
  end

  def self.find_team_users(assignment_id, user_id)
    TeamsUser.joins('INNER JOIN teams ON teams_users.team_id = teams.id')
             .select('teams.id as t_id')
             .where('teams.parent_id = ? and teams_users.user_id = ?', assignment_id, user_id)
  end

  def self.find_user_signup_topics(assignment_id, team_id)
    SignedUpTeam.joins('INNER JOIN sign_up_topics ON signed_up_teams.topic_id = sign_up_topics.id')
                .select('sign_up_topics.id as topic_id, sign_up_topics.topic_name as topic_name, signed_up_teams.is_waitlisted as is_waitlisted,
                  signed_up_teams.preference_priority_number as preference_priority_number')
                .where('sign_up_topics.assignment_id = ? and signed_up_teams.team_id = ?', assignment_id, team_id)
  end

  # If a signup sheet exists then release topics that the given team has selected for the given assignment.
  def self.release_topics_selected_by_team(team_id)
    delete_all_signed_up_topics_for_team(team_id)
    WaitlistTeam.delete_all_waitlists_for_team(team_id)
  end

  def self.topic_id(assignment_id, user_id)
    # team_id variable represents the team_id for this user in this assignment
    team_id = TeamsUser.team_id(assignment_id, user_id)
    topic_id_by_team_id(team_id) if team_id
  end

  def self.topic_id_by_team_id(team_id)
    signed_up_teams = SignedUpTeam.where(team_id: team_id, is_waitlisted: 0)
    if signed_up_teams.blank?
      nil
    else
      signed_up_teams.first.topic_id
    end
  end

  def self.remove_signed_up_team_for_topic(team_id, topic_id)
    signed_up_team = SignedUpTeam.find_by(team_id: team_id, topic_id: topic_id)
    if !signed_up_team.nil?
      ApplicationRecord.transaction do
        signed_up_team.destroy
        signed_up_teams_for_topic = SignedUpTeam.where(topic_id: topic_id)
        max_choosers_for_topic = SignUpTopic.find(topic_id).max_choosers
        if signed_up_teams_for_topic.size < max_choosers_for_topic
          WaitlistTeam.signup_first_waitlist_team topic_id
        end
      end
    end
  end

  def self.delete_all_signed_up_topics_for_team(team_id)
    signed_up_topics = SignedUpTeam.where(team_id: team_id)
    signed_up_topics.each do |signed_up_topic|
      remove_signed_up_team_for_topic(signed_up_topic.team_id, signed_up_topic.topic_id)
    end
  end
end
