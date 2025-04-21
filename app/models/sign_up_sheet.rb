class SignUpSheet < ApplicationRecord
  # Team lazy initialization method [zhewei, 06/27/2015]
  def self.signup_team(assignment_id, user_id, topic_id = nil)
    # Find the team ID for the given assignment and user
    team_id = Team.find_team_users(assignment_id, user_id)&.first&.t_id
    # If the team doesn't exist, create a new team and assign the team ID
    if team_id.nil?
      team = AssignmentTeam.create_team_with_users(assignment_id, [user_id])
      team_id = team.id
    end

    # Confirm the signup topic if a topic ID is provided
    @signup_topic = SignUpTopic.find_by(id: topic_id)
    Rails.logger.debug "Signup Topic: #{@signup_topic}"
    confirmation_status = false
    unless @signup_topic.nil?
      confirmation_status = @signup_topic.sign_team_up(team_id)

      # Check if the team is waitlisted for the topic
      signed_up_team = SignedUpTeam.find_by(topic_id: topic_id, team_id: team_id)
      if signed_up_team && signed_up_team.is_waitlisted
        Rails.logger.debug "Team #{team_id} is waitlisted for topic #{topic_id}. Skipping mentor assignment."
      else
        # Add the mentor_id from the signup topic as a member of the team
        if @signup_topic.mentor_id
          Rails.logger.debug "Mentor ID found: #{@signup_topic.mentor_id}"
          mentor = User.find_by(id: @signup_topic.mentor_id) # Find the mentor user

          Rails.logger.debug "Mentor User: #{mentor.inspect}"
          if mentor
            team = AssignmentTeam.find(team_id) # Find the team by its ID
            Rails.logger.debug "Assignment Team: #{team.inspect}"

            participant = AssignmentParticipant.find_by(parent_id: assignment_id, user_id: mentor.id)

            unless participant
              participant = AssignmentParticipant.create(handle: mentor.handle, parent_id: assignment_id, user_id: mentor.id, can_mentor: 1)
            end

            if participant.persisted?
              Rails.logger.debug "Participant created successfully with ID: #{participant.id}"
              # Further code to execute upon successful creation
            else
              Rails.logger.error "Failed to create participant. Errors: #{participant.errors.full_messages}"
              # Handle the error, e.g., display a message to the user
            end

            result = team.add_mentor(mentor)
            Rails.logger.debug "Add member to team result: #{result}"
          end
        end
      end
    end
    # Log the signup topic save status
    ExpertizaLogger.info "The signup topic save status:#{confirmation_status} for assignment #{assignment_id} by #{user_id}"
    confirmation_status
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