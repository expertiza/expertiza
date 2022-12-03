class WaitlistTeam < ApplicationRecord
  belongs_to :topic, class_name: 'SignUpTopic'
  belongs_to :team, class_name: 'Team'

  validates :topic_id, :team_id, presence: true
  validates :topic_id, uniqueness: { scope: :team_id }
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
