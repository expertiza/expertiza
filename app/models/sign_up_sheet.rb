class SignUpSheet < ApplicationRecord
  # Team lazy initialization method [zhewei, 06/27/2015]
  def self.signup_team(assignment_id, user_id, topic_id = nil)
    # Find the team ID for the given assignment and user
    team_id = SignedUpTeam.find_team_users(assignment_id, user_id)&.first&.t_id
  
    # If the team doesn't exist, create a new team and assign the team ID
    if team_id.nil?
      team = AssignmentTeam.create_team_with_users(assignment_id, [user_id])
      team_id = team.id
    end
  
    # Confirm the signup topic if a topic ID is provided
    confirmation_status = SignUpSheet.confirm_topic(user_id, team_id, topic_id, assignment_id) if topic_id
  
    # Log the signup topic save status
    ExpertizaLogger.info "The signup topic save status:#{confirmation_status} for assignment #{assignment_id} by #{user_id}"
    confirmation_status
  end

  # Confirm a topic for a user within a team for a specific assignment
  def self.confirm_topic(user_id, team_id, topic_id, assignment_id)
    # Fetch all topics for the user within the team for the assignment
    user_signup = SignedUpTeam.find_user_signup_topics(assignment_id, team_id)
    # Fetch users within the team and obtain team details
    users_team = SignedUpTeam.find_team_users(assignment_id, user_id)
    team = Team.find(users_team.first.t_id)

    # Check if the topic is already signed up by the team, return false if exists
    return false if SignedUpTeam.where(team_id: team.id, topic_id: topic_id).any?

    # Create a new SignedUpTeam instance with the provided topic and team details
    sign_up = SignedUpTeam.new(topic_id: topic_id, team_id: team_id)
    result = false

    if user_signup.empty?
      # If there are no topics for the user within the team, proceed with signing up
      ApplicationRecord.transaction do
        # Create a signup_team entry for the team if the slot is available or waitlist it
        team_id, topic_id = create_signup_team(assignment_id, sign_up, topic_id, user_id)
        result = true if sign_up.save
      end
    else
      # If the user is already signed up for a topic, then return false
      return false unless user_signup.first&.is_waitlisted == true

      #If the team has a waitlisted topic, then assign it to a 
      ApplicationRecord.transaction do
        result = signup_team_for_chosen_topic(assignment_id, sign_up, team_id, topic_id)
      end
    end

    result # Return the result of the confirmation process
  end

  # Method to handle the process when a user signs up and is on the waitlist
  def self.signup_team_for_chosen_topic(assignment_id, sign_up, team_id, topic_id)
    if slot_available?(topic_id)
      # Assign the topic to the team if a slot is available and drop off the team from all waitlists
      assign_topic_to_team(sign_up, topic_id)
      #Once assigned, drop all the waitlisted topics for this team
      result = SignedUpTeam.drop_off_waitlists(team_id)
    else
      # Save the team as waitlisted if no slots are available
      result = save_waitlist_entry(sign_up, team_id)
    end
    result
  end

  # Method to assign a topic to the team and update the waitlist status
  def self.assign_topic_to_team(sign_up, topic_id)
    # Set the team's waitlist status to false as they are assigned a topic
    sign_up.update(is_waitlisted: false)
    # Update the topic_id in the signed_up_teams table for the user
    signed_up_team = SignedUpTeam.find_by(topic_id: topic_id)
    signed_up_team.update(topic_id: topic_id) if signed_up_team
  end

  # Method to save the user as waitlisted if no slots are available
  def self.save_waitlist_entry(sign_up, team_id)
    sign_up.is_waitlisted = true
    # Save the user's waitlist status
    result = sign_up.save
    # Log the creation of the sign-up sheet for the waitlisted user
    ExpertizaLogger.info(LoggerMessage.new('SignUpSheet', '', "Sign up sheet created for waitlisted with teamId #{team_id}"))
    result
  end

  def self.create_signup_team(assignment_id, sign_up, topic_id, user_id)
    if slot_available?(topic_id)
      sign_up.is_waitlisted = false
      # Create new record in signed_up_teams table
      team_id = TeamsUser.team_id(assignment_id, user_id)
      topic_id = SignedUpTeam.topic_id(assignment_id, user_id)
      SignedUpTeam.create(topic_id: topic_id, team_id: team_id, is_waitlisted: 0, preference_priority_number: nil)
      ExpertizaLogger.info LoggerMessage.new('SignUpSheet', user_id, "Sign up sheet created with teamId #{team_id}")
    else
      sign_up.is_waitlisted = true
    end
    [team_id, topic_id]
  end

  # When using this method when creating fields, update race conditions by using db transactions
  def self.slot_available?(topic_id)
    SignUpTopic.slot_available?(topic_id)
  end

  def self.add_signup_topic(assignment_id)
    @review_rounds = Assignment.find(assignment_id).num_review_rounds
    @topics = SignUpTopic.where(assignment_id: assignment_id)
    @duedates = {}
    return @duedates if @topics.nil?

    @topics.each_with_index do |topic, i|
      @duedates[i] = duedate = {}
      duedate['id'] = topic.id
      duedate['topic_identifier'] = topic.topic_identifier
      duedate['topic_name'] = topic.topic_name

      (1..@review_rounds).each do |round|
        process_review_round(assignment_id, duedate, round, topic)
      end

      deadline_type_subm = DeadlineType.find_by(name: 'metareview').id
      duedate_subm = TopicDueDate.where(parent_id: topic.id, deadline_type_id: deadline_type_subm).first
      subm_string = duedate_subm.nil? ? nil : DateTime.parse(duedate_subm['due_at'].to_s).strftime('%Y-%m-%d %H:%M:%S')
      duedate['submission_' + (@review_rounds + 1).to_s] = subm_string
    end
    @duedates
  end

  def self.has_teammate_ads?(topic_id)
    teams = Team.joins('INNER JOIN signed_up_teams ON signed_up_teams.team_id = teams.id')
                .select('teams.*')
                .where('teams.advertise_for_partner = 1 and signed_up_teams.topic_id = ?', topic_id).to_a
    teams.reject!(&:full?)
    teams.any?
  end

  class << self
    private

    def process_review_round(assignment_id, duedate, round, topic)
      duedate_rev, duedate_subm = find_topic_duedates(round, topic)

      if duedate_subm.nil? || duedate_rev.nil?
        # the topic is new. so copy deadlines from assignment
        set_of_due_dates = AssignmentDueDate.where(parent_id: assignment_id)
        set_of_due_dates.each do |due_date|
          DeadlineHelper.create_topic_deadline(due_date, 0, topic.id)
        end
        duedate_rev, duedate_subm = find_topic_duedates(round, topic)
      end

      duedate['submission_' + round.to_s] = DateTime.parse(duedate_subm['due_at'].to_s).strftime('%Y-%m-%d %H:%M:%S')
      duedate['review_' + round.to_s] = DateTime.parse(duedate_rev['due_at'].to_s).strftime('%Y-%m-%d %H:%M:%S')
    end

    def find_topic_duedates(round, topic)
      deadline_type_subm = DeadlineType.find_by(name: 'submission').id
      duedate_subm = TopicDueDate.where(parent_id: topic.id, deadline_type_id: deadline_type_subm, round: round).first
      deadline_type_rev = DeadlineType.find_by(name: 'review').id
      duedate_rev = TopicDueDate.where(parent_id: topic.id, deadline_type_id: deadline_type_rev, round: round).first
      [duedate_rev, duedate_subm]
    end
  end

  def self.import(row_hash, session, _id = nil)
    raise 'Not enough items: expect 2 or more columns: Topic Identifier, User Name 1, User Name 2, ...' if row_hash.length < 2

    imported_topic = SignUpTopic.where(topic_identifier: row_hash[:topic_identifier], assignment_id: session[:assignment_id]).first

    raise ImportError, 'Topic, ' + row_hash[:topic_identifier].to_s + ', was not found.' if imported_topic.nil?

    params = 1
    while row_hash.length > params
      index = 'user_name_' + params.to_s

      user = User.find_by(name: row_hash[index.to_sym].to_s)
      raise ImportError, 'The user, ' + row_hash[index.to_sym].to_s.strip + ', was not found.' if user.nil?

      participant = AssignmentParticipant.where(parent_id: session[:assignment_id], user_id: user.id).first
      raise ImportError, 'The user, ' + row_hash[index.to_sym].to_s.strip + ', not present in the assignment.' if participant.nil?

      signup_team(session[:assignment_id], user.id, imported_topic.id)
      params += 1
    end
  end
end