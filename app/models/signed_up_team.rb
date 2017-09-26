class SignedUpTeam < ActiveRecord::Base
  belongs_to :topic, class_name: 'SignUpTopic'
  belongs_to :team, class_name: 'Team'

  # the below has been added to make is consistent with the database schema
  validates :topic_id, :team_id, presence: true
  scope :by_team_id, ->(team_id) { where("team_id = ?", team_id) }

  def self.find_team_participants(assignment_id)
    @participants = SignedUpTeam.joins('INNER JOIN sign_up_topics ON signed_up_teams.topic_id = sign_up_topics.id')
                                .select('signed_up_teams.id as id, sign_up_topics.id as topic_id, sign_up_topics.topic_name as name,
                                  sign_up_topics.topic_name as team_name_placeholder, sign_up_topics.topic_name as user_name_placeholder,
                                  signed_up_teams.is_waitlisted as is_waitlisted, signed_up_teams.team_id as team_id')
                                .where('sign_up_topics.assignment_id = ?', assignment_id)
    i = 0
    @participants.each do |participant|
      participant_names = User.joins('INNER JOIN teams_users ON users.id = teams_users.user_id')
                              .joins('INNER JOIN teams ON teams.id = teams_users.team_id')
                              .select('users.name as u_name, teams.name as team_name')
                              .where('teams.id = ?', participant.team_id)

      team_name_added = false
      names = '(missing team)'

      participant_names.each do |participant_name|
        if !team_name_added
          names = "[" + participant_name.team_name + "] " + participant_name.u_name + " "
          participant.team_name_placeholder = participant_name.team_name
          participant.user_name_placeholder = participant_name.u_name + " "
          team_name_added = true
        else
          names += participant_name.u_name + " "
          participant.user_name_placeholder += participant_name.u_name + " "
        end
      end
      @participants[i].name = names
      i += 1
    end

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
  def self.release_topics_selected_by_team_for_assignment(team_id, assignment_id)
    old_teams_signups = SignedUpTeam.where(team_id: team_id)

    # If the team has signed up for the topic and they are on the waitlist then remove that team from the waitlist.
    unless old_teams_signups.nil?
      old_teams_signups.each do |old_teams_signup|
        if old_teams_signup.is_waitlisted == false # i.e., if the old team was occupying a slot, & thus is releasing a slot ...
          first_waitlisted_signup = SignedUpTeam.find_by(topic_id: old_teams_signup.topic_id, is_waitlisted:  true)
          unless first_waitlisted_signup.nil?
            Invitation.remove_waitlists_for_team(old_teams_signup.topic_id, assignment_id)
          end
        end
        old_teams_signup.destroy
      end
    end
  end

  # This method is used to returns topic_id from [signed_up_teams] table and the inputs are assignment_id and user_id.
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
end
