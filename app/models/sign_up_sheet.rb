# E1920
# Code Climate mistakenly reports
# "Mass assignment is not restricted using attr_accessible"
# https://github.com/presidentbeef/brakeman/issues/579
#
# Change variable names to snake_case; confirmation_status, sign_up
# Change method names to snake case; confirm_topic, create_sign_up_team,
#   other_confirmed_topic_for_user, slot_available?, teammate_ads?
# Rubyify code

class SignUpSheet < ActiveRecord::Base
  # Team lazy initialization method [zhewei, 06/27/2015]
  # Comment out teamuser line per Code climate
  def self.signup_team(assignment_id, user_id, topic_id = nil)
    users_team = SignedUpTeam.find_team_users(assignment_id, user_id)
    if users_team.empty?
      # if team is not yet created, create new team.
      # create Team and TeamNode
      team = AssignmentTeam.create_team_and_node(assignment_id)
      # user = User.find(user_id)
      # create TeamsUser and TeamUserNode
      # teamuser = ApplicationController.helpers.create_team_users(user, team.id)
      # create SignedUpTeam
      confirmation_status = SignUpSheet.confirm_topic(user_id, team.id, topic_id, assignment_id) if topic_id
    elsif topic_id
      confirmation_status = SignUpSheet.confirm_topic(user_id, users_team[0].t_id, topic_id, assignment_id)
    end
    ExpertizaLogger.info "The signup topic save status:#{confirmation_status} for assignment #{assignment_id} by #{user_id}"
    confirmation_status
  end

  # Change name to confirm_topic per Code Climate
  # Cognitive Complexity and Assignment Branch Condition still exist
  def self.confirm_topic(user_id, team_id, topic_id, assignment_id)
    # check whether user has signed up already
    user_signup = SignUpSheet.other_confirmed_topic_for_user(assignment_id, team_id)

    sign_up = SignedUpTeam.new
    sign_up.topic_id = topic_id
    sign_up.team_id = team_id
    result = false
    if user_signup.empty?

      # Using a DB transaction to ensure atomic inserts
      ActiveRecord::Base.transaction do
        # check whether slots exist (params[:id] = topic_id) or has the user selected another topic
        team_id, topic_id = create_sign_up_team(assignment_id, sign_up, topic_id, user_id)
        result = true if sign_up.save
      end
    else
      # If all the topics choosen by the user are waitlisted,
      # Chnage loop per Code Climate
      user_signup.each do |user_signup_topic|
        return false if user_signup_topic.is_waitlisted == false
      end

      # Using a DB transaction to ensure atomic inserts
      ActiveRecord::Base.transaction do
        # check whether user is clicking on a topic which is not going to place him in the waitlist
        result = sign_up_waitlisted(assignment_id, sign_up, team_id, topic_id)
      end
    end

    result
  end

  # Change method name to sign_up_waitlisted
  # Remove user_id from method signature
  def self.sign_up_waitlisted(assignment_id, sign_up, team_id, topic_id)
    if !slot_available?(topic_id)
      sign_up.is_waitlisted = true
      result = true if sign_up.save
      ExpertizaLogger.info LoggerMessage.new('SignUpSheet', '', "Sign up sheet created for waitlisted with teamId #{team_id}")
    else
      # if slot exist, then confirm the topic for the user and delete all the waitlist for this user
      result = cancel_all_waitlists(assignment_id, sign_up, team_id, topic_id)
    end
    result
  end

  # Change method name to cancel_all_waitlists
  # Change variable name to signed_up_team per Code Climate
  # Change where().first to find_by() per Code Climate
  # Change result=true to true
  # Comment out team_id line
  # Change method signature, remove user_id
  # Change to update_attributes per Code Climate
  def self.cancel_all_waitlists(assignment_id, sign_up, team_id, topic_id)
    Waitlist.cancel_all_waitlists(team_id, assignment_id)
    sign_up.is_waitlisted = false
    sign_up.save
    # Update topic_id in signed_up_teams table with the topic_id
    # team_id = SignedUpTeam.find_team_users(assignment_id, user_id)
    signed_up_team = SignedUpTeam.find_by(topic_id: topic_id)
    signed_up_team.update_attributes('topic_id', topic_id)
    true
  end

  # Change name to create_sign_up_team per Code Climate
  def self.create_sign_up_team(assignment_id, sign_up, topic_id, user_id)
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

  # Change name to other_confirmed_topic_for_user per Code Climate
  # Rubify code
  def self.other_confirmed_topic_for_user(assignment_id, team_id)
    SignedUpTeam.find_user_signup_topics(assignment_id, team_id)
  end

  # When using this method when creating fields, update race conditions by using db transactions
  # Change name to slot_available? per Code Climate
  def self.slot_available?(topic_id)
    SignUpTopic.slotAvailable?(topic_id)
  end

  # Assignment Branch Condition still exists
  # Change for loop per Code Climate
  # Change local variabel to due_date
  # Change DateTime.parse to Time.zone.parse
  def self.add_signup_topic(assignment_id)
    @review_rounds = Assignment.find(assignment_id).num_review_rounds
    @topics = SignUpTopic.where(assignment_id: assignment_id)
    @duedates = {}
    return @duedates if @topics.nil?
    @topics.each_with_index do |topic, i|
      @duedates[i] = due_date = {}
      due_date['id'] = topic.id
      due_date['topic_identifier'] = topic.topic_identifier
      due_date['topic_name'] = topic.topic_name

      # for round in 1..@review_rounds
      1.upto(@review_rounds) do |r|
        process_review_round(assignment_id, due_date, r, topic)
      end

      deadline_type_subm = DeadlineType.find_by(name: 'metareview').id
      due_date_subm = TopicDueDate.find_by(parent_id: topic.id, deadline_type_id: deadline_type_subm)
      subm_string = due_date_subm.nil? ? nil : Time.zone.parse(due_date_subm['due_at'].to_s).strftime("%Y-%m-%d %H:%M:%S")
      due_date['submission_' + (@review_rounds + 1).to_s] = subm_string
    end
    @duedates
  end

  # Change name to teammate_ads? per Code Climate
  def self.teammate_ads?(topic_id)
    teams = Team.joins('INNER JOIN signed_up_teams ON signed_up_teams.team_id = teams.id')
                .select('teams.*')
                .where('teams.advertise_for_partner = 1 and signed_up_teams.topic_id = ?', topic_id).to_a
    teams.reject!(&:full?)
    !teams.empty?
  end

  class << self
    private

    # Assignment Branch Condition still exists
    # Change duedate* to due_date*
    # Change loop variable to d
    # Change DateTime.parse to Time.zone.parse
    def process_review_round(assignment_id, due_date, round, topic)
      due_date_rev, due_date_subm = find_topic_due_dates(round, topic)

      if due_date_subm.nil? || due_date_rev.nil?
        # the topic is new. so copy deadlines from assignment
        set_of_due_dates = AssignmentDueDate.where(parent_id: assignment_id)
        set_of_due_dates.each do |d|
          DeadlineHelper.create_topic_deadline(d, 0, topic.id)
        end
        due_date_rev, due_date_subm = find_topic_due_dates(round, topic)
      end

      due_date['submission_' + round.to_s] = Time.zone.parse(due_date_subm['due_at'].to_s).strftime("%Y-%m-%d %H:%M:%S")
      due_date['review_' + round.to_s] = Time.zone.parse(due_date_rev['due_at'].to_s).strftime("%Y-%m-%d %H:%M:%S")
    end

    # Change name to find_topic_due_dates
    # Change variables to due_date*
    # Change where().first to find_by()
    def find_topic_due_dates(round, topic)
      deadline_type_subm = DeadlineType.find_by(name: 'submission').id
      due_date_subm = TopicDueDate.find_by(parent_id: topic.id, deadline_type_id: deadline_type_subm, round: round)
      deadline_type_rev = DeadlineType.find_by(name: 'review').id
      due_date_rev = TopicDueDate.find_by(parent_id: topic.id, deadline_type_id: deadline_type_rev, round: round)
      [due_date_rev, due_date_subm]
    end
  end

  # Assignment Branch Condition and Cognitive Complexity still exists
  # Change where().first to find_by() per Code Climate
  def self.import(row_hash, session, _id = nil)
    raise 'Not enough items: expect 2 or more columns: Topic Identifier, User Name 1, User Name 2, ...' if row_hash.length < 2

    imported_topic = SignUpTopic.find_by(topic_identifier: row_hash[:topic_identifier], assignment_id: session[:assignment_id])

    raise ImportError, "Topic, " + row_hash[:topic_identifier].to_s + ", was not found." if imported_topic.nil?

    params = 1
    while row_hash.length > params
      index = 'user_name_' + params.to_s

      user = User.find_by(name: row_hash[index.to_sym].to_s)
      raise ImportError, "The user, " + row_hash[index.to_sym].to_s.strip + ", was not found." if user.nil?

      participant = AssignmentParticipant.find_by(parent_id: session[:assignment_id], user_id: user.id)
      raise ImportError, "The user, " + row_hash[index.to_sym].to_s.strip + ", not present in the assignment." if participant.nil?

      signup_team(session[:assignment_id], user.id, imported_topic.id)
      params += 1
    end
  end
end
