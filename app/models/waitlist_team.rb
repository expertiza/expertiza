class WaitlistTeam < ApplicationRecord
  belongs_to :topic, class_name: 'SignUpTopic'
  belongs_to :team, class_name: 'Team'

  validates :topic_id, :team_id, presence: true
  validates :topic_id, uniqueness: { scope: :team_id }

  def self.add_team_to_topic_waitlist(team_id, topic_id, user_id)
    new_waitlist = WaitlistTeam.new
    new_waitlist.topic_id = topic_id
    new_waitlist.team_id = team_id
    if new_waitlist.valid?
      WaitlistTeam.create(topic_id: topic_id, team_id: team_id)
    else
      ExpertizaLogger.info LoggerMessage.new('WaitlistTeam', user_id, "Team #{team_id} cannot be added to waitlist for the topic #{topic_id}")
      ExpertizaLogger.info LoggerMessage.new('WaitlistTeam', user_id, new_waitlist.errors.full_messages.join(" "))
      return false
    end
    return true
  end

  def self.remove_team_from_topic_waitlist(team_id, topic_id, user_id)
    waitlisted_team_for_topic = WaitlistTeam.find_by(topic_id: topic_id, team_id: team_id)
    unless waitlisted_team_for_topic.nil?
      waitlisted_team_for_topic.destroy
    else
      ExpertizaLogger.info LoggerMessage.new('WaitlistTeam', user_id, "Cannot find Team #{team_id} in waitlist for the topic #{topic_id} to be deleted.")
    end
    return true
  end
  
  def self.cancel_all_waitlists(team_id, assignment_id)
    waitlisted_topics = SignUpTopic.find_waitlisted_topics(assignment_id, team_id)
    unless waitlisted_topics.nil?
      waitlisted_topics.each do |waitlisted_topic|
        entry = SignedUpTeam.find_by(topic_id: waitlisted_topic.id)
        next if entry.nil?

        entry.destroy
      end
    end
  end

  def self.remove_from_waitlists(team_id)
    signups = SignedUpTeam.where(team_id: team_id)
    signups.each do |signup|
      signup_topic_id = signup.topic_id
      signup.destroy
      non_waitlisted_users = SignedUpTeam.where(topic_id: signup_topic_id, is_waitlisted: false)
      max_choosers = SignUpTopic.find(signup_topic_id).max_choosers
      next unless non_waitlisted_users.length < max_choosers

      first_waitlisted_team = SignedUpTeam.find_by(topic_id: signup_topic_id, is_waitlisted: true)
      SignUpTopic.assign_to_first_waiting_team(first_waitlisted_team) if first_waitlisted_team
    end
  end
end
