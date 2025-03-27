class SignUpTopic < ApplicationRecord
  has_many :signed_up_teams, foreign_key: 'topic_id', dependent: :destroy
  has_many :teams, through: :signed_up_teams # list all teams choose this topic, no matter in waitlist or not
  has_many :due_dates, class_name: 'TopicDueDate', foreign_key: 'parent_id', dependent: :destroy
  has_many :bids, foreign_key: 'topic_id', dependent: :destroy
  has_many :assignment_questionnaires, class_name: 'AssignmentQuestionnaire', foreign_key: 'topic_id', dependent: :destroy
  belongs_to :assignment

  has_paper_trail

  # the below relations have been added to make it consistent with the database schema
  validates :topic_name, :assignment_id, :max_choosers, presence: true
  validates :topic_identifier, length: { maximum: 10 }

  # This method is not used anywhere
  # def get_team_id_from_topic_id(user_id)
  #  return find_by_sql("select t.id from teams t,teams_participants u where t.id=u.team_id and u.user_id = 5");
  # end

  def self.import(row_hash, session, _id = nil)
    if row_hash.length < 3
      raise ArgumentError, 'The CSV File expects the format: Topic identifier, Topic name, Max choosers, Topic Category (optional), Topic Description (Optional), Topic Link (optional).'
    end

    topic = SignUpTopic.where(topic_name: row_hash[:topic_name], assignment_id: session[:assignment_id]).first
    if topic.nil?
      attributes = ImportTopicsHelper.define_attributes(row_hash)

      ImportTopicsHelper.create_new_sign_up_topic(attributes, session)
    else
      topic.max_choosers = row_hash[:max_choosers]
      topic.topic_identifier = row_hash[:topic_identifier]
      # topic.assignment_id = session[:assignment_id]
      topic.save
    end
  end

  def self.find_slots_filled(assignment_id)
    # SignUpTopic.find_by_sql("SELECT topic_id as topic_id, COUNT(t.max_choosers) as count FROM sign_up_topics t JOIN signed_up_teams u ON t.id = u.topic_id WHERE t.assignment_id =" + assignment_id+  " and u.is_waitlisted = false GROUP BY t.id")
    SignUpTopic.find_by_sql(['SELECT topic_id as topic_id, COUNT(t.max_choosers) as count FROM sign_up_topics t JOIN signed_up_teams u ON t.id = u.topic_id WHERE t.assignment_id = ? and u.is_waitlisted = false GROUP BY t.id', assignment_id])
  end

  def self.find_slots_waitlisted(assignment_id)
    # SignUpTopic.find_by_sql("SELECT topic_id as topic_id, COUNT(t.max_choosers) as count FROM sign_up_topics t JOIN signed_up_teams u ON t.id = u.topic_id WHERE t.assignment_id =" + assignment_id +  " and u.is_waitlisted = true GROUP BY t.id")
    SignUpTopic.find_by_sql(['SELECT topic_id as topic_id, COUNT(t.max_choosers) as count FROM sign_up_topics t JOIN signed_up_teams u ON t.id = u.topic_id WHERE t.assignment_id = ? and u.is_waitlisted = true GROUP BY t.id', assignment_id])
  end

  def self.find_waitlisted_topics_for_team(assignment_id, team_id)
    # SignedUpTeam.find_by_sql("SELECT u.id FROM sign_up_topics t, signed_up_teams u WHERE t.id = u.topic_id and u.is_waitlisted = true and t.assignment_id = " + assignment_id.to_s + " and u.team_id = " + team_id.to_s)
    SignedUpTeam.find_by_sql(['SELECT u.id FROM sign_up_topics t, signed_up_teams u WHERE t.id = u.topic_id and u.is_waitlisted = true and t.assignment_id = ? and u.team_id = ?', assignment_id.to_s, team_id.to_s])
  end

  def slot_available?
    topic_id = self.id
    # Retrieve the SignUpTopic record based on the given topic_id
    topic = SignUpTopic.find(topic_id)
    
    # Find the number of students who have selected the topic and are not waitlisted
    no_of_students_who_selected_the_topic = SignedUpTeam.where(topic_id: topic_id, is_waitlisted: false)
  
    # Check if no students have selected the topic yet
    if no_of_students_who_selected_the_topic.nil?
      return true
    else
      # Check if the number of students who selected the topic is less than the maximum allowed
      if topic.max_choosers > no_of_students_who_selected_the_topic.size
        return true # There are available slots for this topic
      else
        return false # All slots for this topic are filled
      end
    end
  end  

  def self.assign_to_first_waiting_team(next_wait_listed_team)
    team_id = next_wait_listed_team.team_id
    team = Team.find(team_id)
    assignment_id = team.parent_id
    next_wait_listed_team.is_waitlisted = false
    next_wait_listed_team.save
    Waitlist.cancel_all_waitlists(team_id, assignment_id)
  end

  def update_waitlisted_users(max_choosers)
    num_of_users_promotable = max_choosers.to_i - self.max_choosers.to_i
    num_of_users_promotable.times do
      next_wait_listed_team = SignedUpTeam.where(topic_id: id, is_waitlisted: true).first
      # if slot exist, then confirm the topic for this team and delete all waitlists for this team
      SignUpTopic.assign_to_first_waiting_team(next_wait_listed_team) if next_wait_listed_team
    end
  end

  def self.has_suggested_topic?(assignment_id)
    sign_up_topics = SignUpTopic.where(assignment_id: assignment_id, private_to: nil)
    all_topics = SignUpTopic.where(assignment_id: assignment_id)
    sign_up_topics.size != all_topics.size
  end

  def users_on_waiting_list
    waitlisted_signed_up_teams = SignedUpTeam.where(topic_id: id, is_waitlisted: 1)
    waitlisted_users = []
    if waitlisted_signed_up_teams.present?
      waitlisted_signed_up_teams.each do |waitlisted_signed_up_team|
        assignment_team = AssignmentTeam.find(waitlisted_signed_up_team.team_id)
        waitlisted_users << assignment_team.users
      end
    end
    waitlisted_users.flatten
  end

  def format_for_display
    topic_display = ''
    topic_display += topic_identifier.to_s + ' - '
    topic_display + topic_name
  end

  # E2121 Line 160: Refactor approve_suggestion to indicate that notification is being sent
  def self.new_topic_from_suggestion(suggestion)
    signuptopic = SignUpTopic.new
    signuptopic.topic_identifier = 'S' + Suggestion.where('assignment_id = ? and id <= ?', suggestion.assignment_id, suggestion.id).size.to_s
    signuptopic.topic_name = suggestion.title
    signuptopic.assignment_id = suggestion.assignment_id
    signuptopic.max_choosers = 1
    # return this model based on these checks
    if signuptopic.save && suggestion.update_attribute('status', 'Approved')
      return signuptopic
    else
      return 'failed'
    end
  end

  def longest_waiting_team(topic_id)
    # Find and return the team that has been waiting the longest for the specified topic.

    # Find the first waitlisted user (team) for the given topic by querying the SignedUpTeam table.
    # Check for records where the topic_id matches the specified topic_id and is_waitlisted is true.
    first_waitlisted_user = SignedUpTeam.where(topic_id: topic_id, is_waitlisted: true).first   
    # If a waitlisted user (team) is found, return it as the team that has been waiting the longest.
    unless first_waitlisted_user.nil?
      return first_waitlisted_user
    end 
    # If no waitlisted user is found, return nil to indicate that there are no teams waiting.
    return nil
  end

  def reassign_topic(team_id)
    # Reassigns topic when a team is dropped from a topic.
    # Get the topic ID for reassignment.
    topic_id = self.id
    # Fetch the record in SignedUpTeam where topic_id matches the topic that needs reassignment
    # and team_id matches the provided team_id. Retrieve the first matching record.
    signup_record = SignedUpTeam.where(topic_id: topic_id, team_id:  team_id).first
    # If the signup record is not marked as waitlisted (is_waitlisted is either false or nil),
    # proceed with reassignment.
    unless signup_record.try(:is_waitlisted)
      # Find the longest waiting team for the same topic.
      longest_waiting_team  = longest_waiting_team(topic_id)
      # If a longest waiting team is found, proceed with reassignment.
      unless longest_waiting_team.nil?
        # Assign the topic to the longest waiting team.
        # Update the is_waitlisted boolean to false for the longest waiting team.
        longest_waiting_team.is_waitlisted = false
        longest_waiting_team.save
        # Drop all waitlisted records for that team.
        SignedUpTeam.drop_off_waitlists(longest_waiting_team.team_id)
      end
    end
    # Delete the entry for the team that was either previously assigned or waiting.
    SignedUpTeam.drop_signup_record(topic_id, team_id)
  end

  # Method to handle the process when a user signs up
  def sign_team_up(team_id)
    topic_id = self.id
    team = Team.find(team_id)
    # Fetch all topics for the user within the team for the assignment
    user_signup = SignedUpTeam.find_user_signup_topics(team.parent_id, team_id)
    # Check if the user is already signed up and waitlisted for the topic
    if !user_signup.empty?
      return false unless user_signup.first&.is_waitlisted == true
    end
    # Create a new SignedUpTeam instance with the provided topic and team details
    signup = SignedUpTeam.new(topic_id: topic_id, team_id: team_id)
    @signed_topic = SignUpTopic.find_by(id: topic_id)
    if @signed_topic.slot_available?
      # Assign the topic to the team if a slot is available and drop off the team from all waitlists
      SignUpTopic.assign_topic_to_team(signup, topic_id)
      # Once assigned, drop all the waitlisted topics for this team
      result = SignedUpTeam.drop_off_waitlists(team_id)
    else
      # Save the team as waitlisted if no slots are available
      result = SignUpTopic.save_waitlist_entry(signup, team_id)
    end
    result
  end

  # Method to assign a topic to the team and update the waitlist status
  def self.assign_topic_to_team(signup, topic_id)
    # Set the team's waitlist status to false as they are assigned a topic
    signup.update(is_waitlisted: false)
    # Update the topic_id in the signed_up_teams table for the user
    signed_up_team = SignedUpTeam.find_by(topic_id: topic_id)
    signed_up_team.update(topic_id: topic_id) if signed_up_team
  end

  # Method to save the user as waitlisted if no slots are available
  def self.save_waitlist_entry(signup, team_id)
    signup.is_waitlisted = true
    # Save the user's waitlist status
    result = signup.save
    # Log the creation of the sign-up sheet for the waitlisted user
    ExpertizaLogger.info(LoggerMessage.new('SignUpSheet', '', "Sign up sheet created for waitlisted with teamId #{team_id}"))
    result
  end

end
