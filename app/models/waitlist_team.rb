class WaitlistTeam < ApplicationRecord
  belongs_to :topic, class_name: 'SignUpTopic'
  belongs_to :team, class_name: 'Team'

  validates :topic_id, :team_id, presence: true
  validates :topic_id, uniqueness: { scope: :team_id }
  scope :by_team_id, ->(team_id) { where('team_id = ?', team_id) }
  scope :by_topic_id, ->(topic_id) { where('topic_id = ?', topic_id) }

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

  def self.remove_team_from_topic_waitlist(team_id, topic_id,user_id)
    waitlisted_team_for_topic = WaitlistTeam.find_by(topic_id: topic_id, team_id: team_id)
    unless waitlisted_team_for_topic.nil?
      waitlisted_team_for_topic.destroy
    else
      ExpertizaLogger.info LoggerMessage.new('WaitlistTeam', user_id, "Cannot find Team #{team_id} in waitlist for the topic #{topic_id} to be deleted.")
    end
    return true
  end

  def self.first_team_in_waitlist_for_topic(topic_id)
    waitlisted_team_for_topic = WaitlistTeam.where(topic_id: topic_id).order("created_at ASC").first
    waitlisted_team_for_topic
  end

  def self.team_has_any_waitlists?(team_id)
    return WaitlistTeam.where(team_id: team_id).empty?
  end

  def self.topic_has_any_waitlists?(topic_id)
    return WaitlistTeam.where(topic_id: topic_id).empty?
  end

  def self.delete_all_waitlists_for_team(team_id, assignment_id)
    waitlisted_topics_for_team = get_all_waitlists_for_team team_id, assignment_id
    unless waitlisted_topics_for_team.nil?
      waitlisted_topics_for_team.each do |entry|
        entry.destroy
      end
    else
      ExpertizaLogger.info LoggerMessage.new('WaitlistTeam', user_id, "Cannot find Team #{team_id} in waitlist.")
    end
    return true
  end

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

  def self.get_all_waitlists_for_team(team_id, assignment_id)
    WaitlistTeam.joins(:topic).where(team_id: team_id, sign_up_topics: {assignment_id: assignment_id})
  end

  def self.get_all_waitlists_for_team(team_id)
    WaitlistTeam.where(team_id: team_id)
  end

  def self.get_all_waitlists_for_topic(topic_id)
    WaitlistTeam.where(topic_id: topic_id)
  end

  def self.count_all_waitlists_per_topic_per_assignment(assignment_id)
    list_of_topic_waitlist_counts = []
    assignment_topics = Assignment.find(assignment_id).sign_up_topics 
    assignment_topics.each do |topic|
      list_of_topic_waitlist_counts.append({topic_id: topic.id, count: topic.waitlist_teams.size})
    end
    list_of_topic_waitlist_counts
  end

  def self.check_team_waitlisted_for_topic(team_id,topic_id)
    if WaitlistTeam.exists?(team_id: team_id, topic_id: topic_id)
      return true
    end
    return false
  end

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
        else
          ExpertizaLogger.info LoggerMessage.new('WaitlistTeam', session[:user].id, "Cannot find Topic #{topic_id} in waitlist.")
          raise ActiveRecord::Rollback
        end
      end
    end
    sign_up_waitlist_team
  end
end