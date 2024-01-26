class SignUpSheet < ApplicationRecord
  # Team lazy initialization method [zhewei, 06/27/2015]
  def self.signup_team(assignment_id, user_id, topic_id = nil)
    users_team = SignedUpTeam.find_team_users(assignment_id, user_id)
    if users_team.empty?
      # if team is not yet created, create new team.
      # create Team and TeamNode
      team = AssignmentTeam.create_team_with_users(assignment_id, [user_id])
      # create SignedUpTeam
      confirmationStatus = SignUpSheet.confirmTopic(user_id, team.id, topic_id, assignment_id) if topic_id
    else
      confirmationStatus = SignUpSheet.confirmTopic(user_id, users_team[0].t_id, topic_id, assignment_id) if topic_id
    end
    ExpertizaLogger.info "The signup topic save status:#{confirmationStatus} for assignment #{assignment_id} by #{user_id}"
    confirmationStatus
  end

  def self.confirmTopic(user_id, team_id, topic_id, assignment_id)
    # check whether user has signed up already
    user_signup = SignUpSheet.otherConfirmedTopicforUser(assignment_id, team_id)
    users_team = SignedUpTeam.find_team_users(assignment_id, user_id)
    team = Team.find(users_team.first.t_id)
    if SignedUpTeam.where(team_id: team.id, topic_id: topic_id).any?
      return false
    end

    sign_up = SignedUpTeam.new
    sign_up.topic_id = topic_id
    sign_up.team_id = team_id
    result = false
    if user_signup.empty?

      # Using a DB transaction to ensure atomic inserts
      ApplicationRecord.transaction do
        # check whether slots exist (params[:id] = topic_id) or has the user selected another topic
        team_id, topic_id = create_SignUpTeam(assignment_id, sign_up, topic_id, user_id)
        result = true if sign_up.save
      end
    else
      # This line of code checks if the "user_signup_topic" is on the waitlist. If it is not on the waitlist, then the code returns 
      # false. If it is on the waitlist, the code continues to execute.
      user_signup.each do |user_signup_topic|
        return false unless user_signup_topic.is_waitlisted
      end

      # Using a DB transaction to ensure atomic inserts
      ApplicationRecord.transaction do
        # check whether user is clicking on a topic which is not going to place him in the waitlist
        result = sign_up_wailisted(assignment_id, sign_up, team_id, topic_id)
      end
    end

    result
  end

  def self.sign_up_wailisted(assignment_id, sign_up, team_id, topic_id)
    if slotAvailable?(topic_id)
      # if slot exist, then confirm the topic for the user and delete all the waitlist for this user
      result = cancel_all_wailists(assignment_id, sign_up, team_id, topic_id)
    else
      sign_up.is_waitlisted = true
      result = true if sign_up.save
      ExpertizaLogger.info LoggerMessage.new('SignUpSheet', '', "Sign up sheet created for waitlisted with teamId #{team_id}")
    end
    result
  end

  def self.cancel_all_wailists(assignment_id, sign_up, team_id, topic_id)
    Waitlist.cancel_all_waitlists(team_id, assignment_id)
    sign_up.is_waitlisted = false
    sign_up.save
    # Update topic_id in signed_up_teams table with the topic_id
    signUp = SignedUpTeam.where(topic_id: topic_id).first
    signUp.update_attribute('topic_id', topic_id)
    return true
  end

  def self.create_SignUpTeam(assignment_id, sign_up, topic_id, user_id)
    if slotAvailable?(topic_id)
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

  def self.otherConfirmedTopicforUser(assignment_id, team_id)
    user_signup = SignedUpTeam.find_user_signup_topics(assignment_id, team_id)
    user_signup
  end

  # When using this method when creating fields, update race conditions by using db transactions
  def self.slotAvailable?(topic_id)
    SignUpTopic.slotAvailable?(topic_id)
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
