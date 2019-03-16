class Waitlist < ActiveRecord::Base
  def self.cancel_all_waitlists(team_id, assignment_id)
    waitlisted_topics = SignUpTopic.find_waitlisted_topics(assignment_id, team_id)

    destroy_topics(waitlisted_topics) unless waitlisted_topics.nil?
  end

  private def self.destroy_topics(waitlisted_topics)
    waitlisted_topics.each do |waitlisted_topic|
      entry = SignedUpTeam.find(waitlisted_topic.id)
      entry.destroy
      ExpertizaLogger.info LoggerMessage.new('Waitlist', '', "Waitlisted topic deleted with id: #{waitlisted_topic.id}")
    end
  end
end
