class WaitlistTeam < ApplicationRecord
  belongs_to :topic, class_name: 'SignUpTopic'
  belongs_to :team, class_name: 'Team'

  validates :topic_id, :team_id, presence: true
  validates :topic_id, uniqueness: { scope: :team_id }

  # E2240
  # This method adds an entry in the waitlist_teams table
  # Returns true if a team is succesfully added to a topic waitlist else false
  # @param team_id [Integer]
  # @param topic_id [Integer]
  # @param user_id [Integer]
  # @return true or false [boolean] 
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

  # E2240
  # This method removes an entry in the waitlist_teams table
  # Returns true if a team is succesfully removed from a topic's waitlist else false
  # @param team_id [Integer]
  # @param topic_id [Integer]
  # @param user_id [Integer]
  # @return true or false [boolean]
  def self.remove_team_from_topic_waitlist(team_id, topic_id,user_id)
    waitlisted_team_for_topic = WaitlistTeam.find_by(topic_id: topic_id, team_id: team_id)
    unless waitlisted_team_for_topic.nil?
      waitlisted_team_for_topic.destroy
    else
      ExpertizaLogger.info LoggerMessage.new('WaitlistTeam', user_id, "Cannot find Team #{team_id} in waitlist for the topic #{topic_id} to be deleted.")
    end
    return true
  end

  # E2240
  # This method adds an entry in the waitlist_teams table
  # Returns first waitlist team for the topic 
  # @param topic_id [Integer]
  # @return WaitlistTeam Object [WaitlistTeam] 
  def self.first_team_in_waitlist_for_topic(topic_id)
    waitlisted_team_for_topic = WaitlistTeam.where(topic_id: topic_id).order("created_at ASC").first
    waitlisted_team_for_topic
  end

  # E2240
  # This method checks if a team has waitlists for any topic
  # Returns records from the waitlist teams table that match the parameters(team_id) supplied
  # @param team_id [Integer] - team_id from teams table
  # @return an array of WaitlistTeam objects [Array] 
  def self.team_has_any_waitlists?(team_id)
    WaitlistTeam.where(team_id: team_id).empty?
  end

  # E2240
  # This method checks if a topic has waitlists for any team
  # Returns records from the waitlist teams table that match the parameters(topic_id) supplied
  # @param topic_id [Integer] - topic_id from sign_up_topics tables
  # @return an array of WaitlistTeam objects [Array] 
  def self.topic_has_any_waitlists?(topic_id)
    WaitlistTeam.where(topic_id: topic_id).empty?
  end

  # E2240
  # This method deletes all the waitlists for a team in all the topics
  # Returns true if all the waitlists are destroyed successfully and
  # if there are any errors, it raises an exception
  # @param topic_id [Integer] - topic_id from sign_up_topics tables
  # @param assignment_id [Integer] - assignment_id from assignment_team_table
  # @return true or false [Boolean] 
  def self.delete_all_waitlists_for_team(team_id)
    waitlisted_topics_for_team = get_all_waitlists_for_team team_id
    unless waitlisted_topics_for_team.nil?
      waitlisted_topics_for_team.each do |entry|
       entry.destroy
      end
    else
      ExpertizaLogger.info LoggerMessage.new('WaitlistTeam', user_id, "Cannot find Team #{team_id} in waitlist.")
    end
    return true
  end 

  # E2240
  # This method deletes all the waitlists of a topic
  # Returns true if all the waitlists are destroyed successfully and
  # if there are any errors, it raises an exception
  # @param topic_id [Integer]
  # @return true or false [Boolean] 
  def self.delete_all_waitlists_for_topic(topic_id)
    waitlisted_teams_for_topic = get_all_waitlists_for_topic topic_id
    unless waitlisted_teams_for_topic.nil?
      waitlisted_teams_for_topic.each do |entry|
        entry.destroy
      end
    else
      ExpertizaLogger.info LoggerMessage.new('WaitlistTeam', user_id, "Cannot find Topic #{topic_id} in waitlist.")
    end
    return true
  end

  # E2240
  # This method retrieves all the waitlist of a team
  # Returns records from the waitlist teams table that match the parameters(team_id, assignment_id) supplied. 
  # @param team_id [Integer]
  # @param assignment_id [Integer]
  # @return an array of WaitlistTeam objects [Array] 
  def self.get_all_waitlists_for_team(team_id)
    WaitlistTeam.joins(:topic).select('waitlist_teams.id, topic_name, team_id, topic_id, created_at').where(team_id: team_id)
  end

  # E2240
  # This method retrieves records from waitlist_teams table for a topic
  # Returns records from the waitlist teams table that match the parameters(topic_id) supplied. 
  # @param topic_id [Integer]
  # @param assignment_id [Integer]
  # @return an array of WaitlistTeam objects [Array]
  def self.get_all_waitlists_for_topic(topic_id)
    WaitlistTeam.where(topic_id: topic_id)
  end

  # E2240
  # This method returns the count of teams in waitlist for all the topics in an assignment
  # @param assignment_id [Integer] - assignment_id from assignment_teams table
  # @return a list with topic_id and waitlist count for that topic_id [Array] 
  def self.count_all_waitlists_per_topic_per_assignment(assignment_id)
    list_of_topic_waitlist_counts = []
    assignment_topics = Assignment.find(assignment_id).sign_up_topics 
    assignment_topics.each do |topic|
      list_of_topic_waitlist_counts.append({topic_id: topic.id, count: topic.waitlist_teams.size})
    end
    list_of_topic_waitlist_counts
  end

  
  # E2240
  # This method returns all the teams waitlisted in all topics in an assignment
  # @param assignment_id [Integer] - assignment_id from assignment_teams tables
  # @return an array of WaitlistTeam object [Array]
  def self.find_waitlisted_teams_for_asignment(assignment_id, ip_address = nil)
    waitlisted_participants = WaitlistTeam.joins('INNER JOIN sign_up_topics ON waitlist_teams.topic_id = sign_up_topics.id')
                .select('waitlist_teams.id as id, sign_up_topics.id as topic_id, sign_up_topics.topic_name as name,
                  sign_up_topics.topic_name as team_name_placeholder, sign_up_topics.topic_name as user_name_placeholder,
                  waitlist_teams.team_id as team_id')
                .where('sign_up_topics.assignment_id = ?', assignment_id)
    
    SignedUpTeam.fill_participant_names waitlisted_participants, ip_address
    waitlisted_participants
  end

  # E2240
  # This method checks if a team is waitlisted for a topic
  # @param team_id [Integer] - team_id from teams table
  # @param topic_id [Integer] - topic_id from sign_up_topics tables
  # @return true or false [Boolean]
  def self.check_team_waitlisted_for_topic(team_id,topic_id)
    if WaitlistTeam.exists?(team_id: team_id, topic_id: topic_id)
      return true
    end
    return false
  end


  # E2240
  # This method signs up the first waitlist team whenever a team that is signed up for that topic is dropped/removed
  # After this method is executed successfully, a record entry is created in signed_up_table and 
  # a record entry is deleted in waitlist_team table if there are teams in waitlist for the topic 
  # @param topic_id [Integer] - topic_id from sign_up_topics tables
  # @return SignedUpTeam object [Boolean]
  def self.signup_first_waitlist_team(topic_id)
    sign_up_waitlist_team = nil
    ApplicationRecord.transaction do
      first_waitlist_team = first_team_in_waitlist_for_topic(topic_id)
      unless first_waitlist_team.blank?
        sign_up_waitlist_team = SignedUpTeam.new
        sign_up_waitlist_team.topic_id = first_waitlist_team.topic_id
        sign_up_waitlist_team.team_id = first_waitlist_team.team_id
        if sign_up_waitlist_team.valid?
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