class Waitlist < ActiveRecord::Base
  def self.cancel_all_waitlists(team_id, assignment_id)
    waitlisted_topics = Waitlist.find_waitlisted_topics(assignment_id, team_id)
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
      Waitlist.assign_to_first_waiting_team(first_waitlisted_team) if first_waitlisted_team
    end
  end

  def self.remove_waitlists_for_team(topic_id, _assignment_id)
    # first_waitlisted_signup = SignedUpTeam.where(topic_id: topic_id, is_waitlisted: true).first
    first_waitlisted_signup = Waitlist.first_waitlisted_signup(topic_id)

    # As this user is going to be allocated a confirmed topic, all of his waitlisted topic signups should be purged
    first_waitlisted_signup.is_waitlisted = false
    first_waitlisted_signup.save

    # Cancel all topics the user is waitlisted for
    Waitlist.cancel_all_waitlists(first_waitlisted_signup.team_id, SignUpTopic.find(topic_id).assignment_id)
  end

  def self.find_slots_filled(assignment_id)
    # SignUpTopic.find_by_sql("SELECT topic_id as topic_id, COUNT(t.max_choosers) as count FROM sign_up_topics t JOIN signed_up_teams u ON t.id = u.topic_id WHERE t.assignment_id =" + assignment_id+  " and u.is_waitlisted = false GROUP BY t.id")
    SignUpTopic.find_by_sql(["SELECT topic_id as topic_id, COUNT(t.max_choosers) as count FROM sign_up_topics t JOIN signed_up_teams u ON t.id = u.topic_id WHERE t.assignment_id = ? and u.is_waitlisted = false GROUP BY t.id", assignment_id])
  end

  def self.find_waitlisted_topics(assignment_id, team_id)
    # SignedUpTeam.find_by_sql("SELECT u.id FROM sign_up_topics t, signed_up_teams u WHERE t.id = u.topic_id and u.is_waitlisted = true and t.assignment_id = " + assignment_id.to_s + " and u.team_id = " + team_id.to_s)
    SignedUpTeam.find_by_sql(["SELECT u.id FROM sign_up_topics t, signed_up_teams u WHERE t.id = u.topic_id and u.is_waitlisted = true and t.assignment_id = ? and u.team_id = ?", assignment_id.to_s, team_id.to_s])
  end

  def self.find_slots_waitlisted(assignment_id)
    # SignUpTopic.find_by_sql("SELECT topic_id as topic_id, COUNT(t.max_choosers) as count FROM sign_up_topics t JOIN signed_up_teams u ON t.id = u.topic_id WHERE t.assignment_id =" + assignment_id +  " and u.is_waitlisted = true GROUP BY t.id")
    SignUpTopic.find_by_sql(["SELECT topic_id as topic_id, COUNT(t.max_choosers) as count FROM sign_up_topics t JOIN signed_up_teams u ON t.id = u.topic_id WHERE t.assignment_id = ? and u.is_waitlisted = true GROUP BY t.id", assignment_id])
  end

  def self.first_waitlisted_user(topic_id)
    SignedUpTeam.where(topic_id: topic_id, is_waitlisted: true).first
  end

  def self.assign_to_first_waiting_team(next_wait_listed_team)
    team_id = next_wait_listed_team.team_id
    team = Team.find(team_id)
    assignment_id = team.parent_id
    next_wait_listed_team.is_waitlisted = false
    next_wait_listed_team.save
    Waitlist.cancel_all_waitlists(team_id, assignment_id)
  end

  def self.next_wait_listed_team
    SignedUpTeam.where(topic_id: self.id, is_waitlisted: true).first
  end

  def self.update_waitlisted_users(max_choosers)
    num_of_users_promotable = max_choosers.to_i - self.max_choosers.to_i
    num_of_users_promotable.times do
      next_wait_listed_team = Waitlist.next_wait_listed_team
      # if slot exist, then confirm the topic for this team and delete all waitlists for this team
      Waitlist.assign_to_first_waiting_team(next_wait_listed_team) if next_wait_listed_team
    end
  end

  def self.waitlisted_signed_up_team(topic_id)
    SignedUpTeam.where(topic_id: topic_id, is_waitlisted: 1)
  end

  def self.first_waitlisted_signup(topic_id)
    SignedUpTeam.find_by(topic_id: topic_id, is_waitlisted:  true)
  end

  def self.waitlisted_user_id_from_team_id(team_id)
    TeamsUser.where(team_id: team_id).first.user_id
  end

  def self.teams_not_signed_up(topic_id)
    SignedUpTeam.where(team_id: topic_id, is_waitlisted: 0)
  end
end