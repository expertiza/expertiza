class SignUpSheet < ApplicationRecord
  # Team lazy initialization method [zhewei, 06/27/2015]
  def self.signup_team(assignment_id, user_id, topic_id = nil)
    users_team = SignedUpTeam.find_team_users(assignment_id, user_id)
    if users_team.empty?
      # if team is not yet created, create new team.
      # create Team and TeamNode
      team = AssignmentTeam.create_team_and_node(assignment_id)
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

    sign_up = SignedUpTeam.new
    sign_up.topic_id = topic_id
    sign_up.team_id = team_id
    result = false

    # Using a DB transaction to ensure atomic inserts
    ApplicationRecord.transaction do
      # check whether slots exist (params[:id] = topic_id)
      if slotAvailable?(topic_id)
        result = true if signup_team_to_topic(assignment_id, sign_up, topic_id, user_id, user_signup)
      elsif user_signup.empty?
        # only waitlist team if user doesn't have other signups
        unless WaitlistTeam.add_team_to_topic_waitlist(team_id, topic_id, user_id)
          raise ActiveRecord::Rollback 
        else
          result = true
        end
      end
    end
    result
  end

  def self.signup_team_to_topic(assignment_id, sign_up, topic_id, user_id, user_signup)
    team_id = TeamsUser.team_id(assignment_id, user_id)
    sign_up.is_waitlisted = false
    result = false
    # has the user selected another topic
    unless user_signup.empty?
      SignedUpTeam.delete_all_signed_up_topics_for_team(team_id)
    end

    # Create new record in signed_up_teams table
    result = sign_up.save

    WaitlistTeam.delete_all_waitlists_for_team(team_id,assignment_id)
    ExpertizaLogger.info LoggerMessage.new('SignUpSheet', user_id, "Sign up sheet created with teamId #{team_id}")
    result
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
