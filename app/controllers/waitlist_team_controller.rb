class WaitlistTeamController < ApplicationController
  include AuthorizationHelper

  # Determines first team on waitlist based on date/time of entry
  # into the database
  def self.first_team_in_waitlist_for_topic(topic_id)
    waitlisted_team_for_topic = WaitlistTeam.where(topic_id: topic_id).order("created_at ASC").first
    waitlisted_team_for_topic
  end

  # Searches database for waitlist entries for team
  def self.team_has_any_waitlists?(team_id)
    WaitlistTeam.where(team_id: team_id).empty?
  end

  # Searches database for waitlist entries for topic
  def self.topic_has_any_waitlists?(topic_id)
    WaitlistTeam.where(topic_id: topic_id).empty?
  end

  # Deletes all waitlists for a team across all topics
  def self.delete_all_waitlists_for_team(team_id)
    waitlisted_topics_for_team = get_all_waitlists_for_team team_id
    if !waitlisted_topics_for_team.nil?
      waitlisted_topics_for_team.destroy_all
    else
      ExpertizaLogger.info LoggerMessage.new('WaitlistTeam', user_id, "Cannot find Team #{team_id} in waitlist.")
    end
    return true
  end

  # Deletes all waitlisted teams on a specific topic
  # Removing all entries from the database
  def self.delete_all_waitlists_for_topic(topic_id)
    waitlisted_teams_for_topic = get_all_waitlists_for_topic topic_id
    if !waitlisted_teams_for_topic.nil?
      waitlisted_teams_for_topic.destroy_all
    else
      ExpertizaLogger.info LoggerMessage.new('WaitlistTeam', user_id, "Cannot find Topic #{topic_id} in waitlist.")
    end
    return true
  end

  # Returns list of all waitlist topics for a team
  def self.get_all_waitlists_for_team(team_id)
    WaitlistTeam.joins(:topic).select('waitlist_teams.id, topic_name, team_id, topic_id, created_at').where(team_id: team_id)
  end

  # Returns list of all waitlisted teams for a topic
  def self.get_all_waitlists_for_topic(topic_id)
    WaitlistTeam.where(topic_id: topic_id)
  end

  # Searches through all topics on an assignment to determine waitlist sizes
  def self.count_all_waitlists_per_topic_per_assignment(assignment_id)
    list_of_topic_waitlist_counts = []
    assignment_topics = Assignment.find(assignment_id).sign_up_topics
    assignment_topics.each do |topic|
      list_of_topic_waitlist_counts.append({ topic_id: topic.id, count: topic.waitlist_teams.size })
    end
    list_of_topic_waitlist_counts
  end

  # Searches database for all waitlisted teams for specific assignment
  def self.find_waitlisted_teams_for_assignment(assignment_id, ip_address = nil)
    waitlisted_participants = WaitlistTeam.joins('INNER JOIN sign_up_topics ON waitlist_teams.topic_id = sign_up_topics.id')
                                          .select('waitlist_teams.id as id, sign_up_topics.id as topic_id, sign_up_topics.topic_name as name,
                                            sign_up_topics.topic_name as team_name_placeholder, sign_up_topics.topic_name as user_name_placeholder,
                                            waitlist_teams.team_id as team_id')
                                          .where('sign_up_topics.assignment_id = ?', assignment_id)
    SignedUpTeam.fill_participant_names waitlisted_participants, ip_address
    waitlisted_participants
  end

  # Simple database check to find if waitlisted team exists
  def self.check_team_waitlisted_for_topic(team_id, topic_id)
    WaitlistTeam.exists?(team_id: team_id, topic_id: topic_id)
  end

  # Find team at top of queue and converts to SignedUpTeam
  # Returns team as a SignedUpTeam so it can be moved in proper database
  def self.signup_first_waitlist_team(topic_id)
    sign_up_waitlist_team = nil
    ApplicationRecord.transaction do
      first_waitlist_team = first_team_in_waitlist_for_topic(topic_id)
      unless first_waitlist_team.blank?
        sign_up_waitlist_team = SignedUpTeam.new
        sign_up_waitlist_team.topic_id = first_waitlist_team.topic_id
        sign_up_waitlist_team.team_id = first_waitlist_team.team_id
        if sign_up_waitlist_team.valid?
          sign_up_waitlist_team.is_waitlisted = false
          sign_up_waitlist_team.save
          first_waitlist_team.destroy
          delete_all_waitlists_for_team sign_up_waitlist_team.team_id
        else
          ExpertizaLogger.info LoggerMessage.new('WaitlistTeam', session[:user].id, "Cannot find Topic #{topic_id} in waitlist.")
          raise ActiveRecord::Rollback
        end
      end
    end
    sign_up_waitlist_team
  end
end
