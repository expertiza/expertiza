class SignUpSheet < ActiveRecord::Base
  # Team lazy initialization method [zhewei, 06/27/2015]
  def self.signup_team(assignment_id, user_id, topic_id = nil)
    users_team = SignedUpTeam.find_team_users(assignment_id, user_id)
    if users_team.empty?
      # if team is not yet created, create new team.
      # create Team and TeamNode
      team = AssignmentTeam.create_team_and_node(assignment_id, AssignmentTeam.name)
      user = User.find(user_id)
      # create TeamsUser and TeamUserNode
      teamuser = ApplicationController.helpers.create_team_users(user, team.id)
      # create SignedUpTeam
      confirmationStatus = SignUpSheet.confirmTopic(user_id, team.id, topic_id, assignment_id) if topic_id
    else
      confirmationStatus = SignUpSheet.confirmTopic(user_id, users_team[0].t_id, topic_id, assignment_id) if topic_id
    end
  end

  def self.confirmTopic(user_id, team_id, topic_id, assignment_id)
    # check whether user has signed up already
    user_signup = SignUpSheet.otherConfirmedTopicforUser(assignment_id, team_id)

    sign_up = SignedUpTeam.new
    sign_up.topic_id = topic_id
    sign_up.team_id = team_id
    result = false
    if user_signup.empty?

      # Using a DB transaction to ensure atomic inserts
      ActiveRecord::Base.transaction do
        # check whether slots exist (params[:id] = topic_id) or has the user selected another topic
        team_id, topic_id = create_SignUpTeam(assignment_id, sign_up, topic_id, user_id)
        result = true if sign_up.save
      end
    else
      # If all the topics choosen by the user are waitlisted,
      for user_signup_topic in user_signup
        return false if user_signup_topic.is_waitlisted == false
      end

      # Using a DB transaction to ensure atomic inserts
      ActiveRecord::Base.transaction do
        # check whether user is clicking on a topic which is not going to place him in the waitlist
        result = sign_up_wailisted(assignment_id, sign_up, team_id, topic_id, user_id)
      end
    end

    result
  end

  def self.sign_up_wailisted(assignment_id, sign_up, team_id, topic_id, user_id)
    if !slotAvailable?(topic_id)
      sign_up.is_waitlisted = true
      result = true if sign_up.save
    else
      # if slot exist, then confirm the topic for the user and delete all the waitlist for this user
      result = cancel_all_wailists(assignment_id, sign_up, team_id, topic_id, user_id)
    end
    result
  end

  def self.cancel_all_wailists(assignment_id, sign_up, team_id, topic_id, user_id)
    Waitlist.cancel_all_waitlists(team_id, assignment_id)
    sign_up.is_waitlisted = false
    sign_up.save
    # Update topic_id in signed_up_teams table with the topic_id
    team_id = SignedUpTeam.find_team_users(assignment_id, user_id)
    signUp = SignedUpTeam.where(topic_id: topic_id).first
    signUp.update_attribute('topic_id', topic_id)
    result = true
  end

  def self.create_SignUpTeam(assignment_id, sign_up, topic_id, user_id)
    if slotAvailable?(topic_id)
      sign_up.is_waitlisted = false
      # Create new record in signed_up_teams table
      team_id = TeamsUser.team_id(assignment_id, user_id)
      topic_id = SignedUpTeam.topic_id(assignment_id, user_id)
      SignedUpTeam.create(topic_id: topic_id, team_id: team_id, is_waitlisted: 0, preference_priority_number: nil)
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

    # Use this until you figure out how to initialize this array
    # @duedates = SignUpTopic.find_by_sql("SELECT s.id as topic_id FROM sign_up_topics s WHERE s.assignment_id = " + assignment_id.to_s)
    @duedates = {}
    return @duedates if @topics.nil?
    @topics.each_with_index do |topic, i|
      @duedates[i] = duedate = {}
      duedate['id'] = topic.id
      duedate['topic_identifier'] = topic.topic_identifier
      duedate['topic_name'] = topic.topic_name

      for round in 1..@review_rounds
        process_review_round(assignment_id, duedate, round, topic)
      end

      deadline_type_subm = DeadlineType.find_by_name('metareview').id
      duedate_subm = TopicDueDate.where(parent_id: topic.id, deadline_type_id: deadline_type_subm).first
      subm_string = duedate_subm.nil? ? nil : DateTime.parse(duedate_subm['due_at'].to_s).strftime("%Y-%m-%d %H:%M:%S")
      duedate['submission_' + (@review_rounds + 1).to_s] = subm_string
    end
    @duedates
  end

  def self.has_teammate_ads?(topic_id)
    teams = Team.find_by_sql("select t.* "\
        "from teams t, signed_up_teams s "\
        "where s.topic_id='" + topic_id.to_s + "' and s.team_id = t.id and t.advertise_for_partner = 1")
    teams.reject!(&:full?)
    !teams.empty?
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

      duedate['submission_' + round.to_s] = DateTime.parse(duedate_subm['due_at'].to_s).strftime("%Y-%m-%d %H:%M:%S")
      duedate['review_' + round.to_s] = DateTime.parse(duedate_rev['due_at'].to_s).strftime("%Y-%m-%d %H:%M:%S")
    end

    def find_topic_duedates(round, topic)
      deadline_type_subm = DeadlineType.find_by_name('submission').id
      duedate_subm = TopicDueDate.where(parent_id: topic.id, deadline_type_id: deadline_type_subm, round: round).first
      deadline_type_rev = DeadlineType.find_by_name('review').id
      duedate_rev = TopicDueDate.where(parent_id: topic.id, deadline_type_id: deadline_type_rev, round: round).first
      [duedate_rev, duedate_subm]
    end
  end
end
