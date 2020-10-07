class Waitlist < ActiveRecord::Base
  def self.cancel_all_waitlists(team_id, assignment_id)
    waitlisted_topics = SignUpTopic.find_waitlisted_topics(assignment_id, team_id)
    unless waitlisted_topics.nil?
      for waitlisted_topic in waitlisted_topics
        entry = SignedUpTeam.find(waitlisted_topic.id)
        entry.destroy
        ExpertizaLogger.info LoggerMessage.new('Waitlist', '', "Waitlisted topic deleted with id: #{waitlisted_topic.id}")
      end
    end
  end

  def self.remove_from_waitlists(team_id)
    signups = SignedUpTeam.where team_id: team_id
    signups.each do |signup|
      # get the topic_id
      signup_topic_id = signup.topic_id
      # destroy the signup
      signup.destroy
      # get the number of non-waitlisted users signed up for this topic
      non_waitlisted_users = SignedUpTeam.where topic_id: signup_topic_id, is_waitlisted: false
      # get the number of max-choosers for the topic
      max_choosers = SignUpTopic.find(signup_topic_id).max_choosers
      # check if this number is less than the max choosers
      next unless non_waitlisted_users.length < max_choosers
      first_waitlisted_team = SignedUpTeam.find_by topic_id: signup_topic_id, is_waitlisted: true
      # moving the waitlisted team into the confirmed signed up teams list and delete all waitlists for this team
      SignUpTopic.assign_to_first_waiting_team(first_waitlisted_team) if first_waitlisted_team
    end
  end
end
