module SignUpSheetHelper
  # if the instructor does not specific the topic due date, it should be the same as assignment due date;
  # otherwise, it should display the topic due date.
  def check_topic_due_date_value(assignment_due_dates, topic_id, deadline_type_id = 1, review_round = 1)
    due_date = get_topic_deadline(assignment_due_dates, topic_id, deadline_type_id, review_round)
    due_date ? DateTime.parse(due_date.to_s).strftime('%Y-%m-%d %H:%M:%S') : nil
  end

  def get_topic_deadline(_assignment_due_dates, topic_id, deadline_type_id = 1, review_round = 1)
    topic_due_date = begin
                       TopicDueDate.where(parent_id: topic_id,
                                          deadline_type_id: deadline_type_id,
                                          round: review_round).first
                     rescue StandardError
                       nil
                     end
    topic_due_date.nil? ? topic_due_date : topic_due_date.due_at
  end

  # Retrieve topics suggested by signed in user for
  # the assignment.
  def get_suggested_topics(assignment_id)
    team_id = TeamsUser.team_id(assignment_id, session[:user].id)
    teams_users = TeamsUser.where(team_id: team_id)
    teams_users_array = []
    teams_users.each do |teams_user|
      teams_users_array << teams_user.user_id
    end
    @suggested_topics = SignUpTopic.where(assignment_id: assignment_id, private_to: teams_users_array)
  end

  # Render topic row for intelligent topic selection.
  def get_intelligent_topic_row(topic, selected_topics, max_team_size = 3)
    row_html = ''
    if selected_topics.present?
      selected_topics.each do |selected_topic|
        row_html = if (selected_topic.topic_id == topic.id) && !selected_topic.is_waitlisted
                     '<tr bgcolor="yellow">'
                   elsif (selected_topic.topic_id == topic.id) && selected_topic.is_waitlisted
                     '<tr bgcolor="lightgray">'
                   else
                     '<tr id="topic_' + topic.id.to_s + '">'
                   end
      end
    else
      row_html = '<tr id="topic_' + topic.id.to_s + '" style="background-color:' + get_topic_bg_color(topic, max_team_size) + '">'
    end
    row_html.html_safe
  end

  # Compute background colour for a topic with respect to maximum team size.
  def get_topic_bg_color(topic, max_team_size)
    red = (400 * (1 - (Math.tanh(2 * [max_team_size.to_f / Bid.where(topic_id: topic.id).count, 1].min - 1) + 1) / 2)).to_i.to_s
    green = (400 * (Math.tanh(2 * [max_team_size.to_f / Bid.where(topic_id: topic.id).count, 1].min - 1) + 1) / 2).to_i.to_s
    'rgb(' + red + ',' + green + ',0)'
  end

  # Render the participant info for a topic and assignment.
  def render_participant_info(topic, assignment, participants)
    html = ''
    if participants.present?
      chooser_present = false
      participants.each do |participant|
        next unless topic.id == participant.topic_id
        if participant.team.teams_users.size == 0
          participant.team.destroy
          participant.destroy
          next
        end
        chooser_present = true
        html += participant.user_name_placeholder
        if assignment.max_team_size > 1
          html += '<a href="/sign_up_sheet/delete_signup_as_instructor?' + 'id='+ participant.team_id.to_s + '&topic_id=' + topic.id.to_s + '">'
          html += '<img border="0" align="middle" src="/assets/delete_icon.png" title="Drop Student"></a>'
        end
        html += '<font color="red">(waitlisted)</font>' if participant.is_waitlisted
        html += '<br/>'
      end
      html += 'No choosers.' unless chooser_present
    end
    html.html_safe
  end

  # renders the team's chosen bids in a list sorted by priority
  def team_bids(topic, participants)
    if participants.present? && current_user_has_instructor_privileges?
      team_id = nil
      participants.each do |participant|
        next unless topic.id == participant.topic_id

        team_id = participant.team.try(:id)
      end

      bids = Bid.where(team_id: team_id).order(:priority)
      signed_up_topics = []
      bids.each do |b|
        sign_up_topic = SignUpTopic.find_by(id: b.topic_id)
        signed_up_topics << sign_up_topic if sign_up_topic
      end

      out_string = ''
      signed_up_topics.each_with_index do |t, i|
        out_string += (i + 1).to_s + ". " + t.topic_name + "\r\n"
      end
      out_string
    end
  end

  class SignUpTopicHelper
   # Initializes a new SignUpTopicHelper object.
   # @param params [Hash] The parameters containing information about the sign-up topic.
   # @param assignment_id [Integer] The ID of the assignment to which the sign-up topic belongs.
    def initialize(params, assignment_id)
      @params = params
      @assignment_id = assignment_id
    end
  # Builds a new SignUpTopic object based on the parameters provided.
    def build
      SignUpTopic.new.tap do |topic|
        puts @params.dig(:topic, :topic_identifier)
        topic.topic_identifier = @params.dig(:topic, :topic_identifier)
        topic.topic_name = @params.dig(:topic, :topic_name)
        topic.max_choosers = @params.dig(:topic, :max_choosers)
        topic.category = @params.dig(:topic, :category)
        topic.assignment_id = @assignment_id
      end
    end
  end  
  
  # Creates a new topic due date record.
  # @param index [Integer] The index of the due date.
  # @param topic [SignUpTopic] The sign-up topic for which the due date is being created.
  # @param deadline_type_id [Integer] The ID representing the type of deadline.
  # @param due_date_instance [DueDateInstance] An instance containing due date information.
  # @param due_at [DateTime] The date and time at which the deadline is due.
  # @return [TopicDueDate] A new TopicDueDate object representing the due date record.
  def create_topic_due_date(index,topic,deadline_type_id,due_date_instance,due_at)
    TopicDueDate.create(
              due_at: due_at,
              deadline_type_id: deadline_type_id,
              parent_id: topic.id,
              submission_allowed_id: due_date_instance.submission_allowed_id,
              review_allowed_id: due_date_instance.review_allowed_id,
              review_of_review_allowed_id: due_date_instance.review_of_review_allowed_id,
              round: index,
              flag: due_date_instance.flag,
              threshold: due_date_instance.threshold,
              delayed_job_id: due_date_instance.delayed_job_id,
              deadline_name: due_date_instance.deadline_name,
              description_url: due_date_instance.description_url,
              quiz_allowed_id: due_date_instance.quiz_allowed_id,
              teammate_review_allowed_id: due_date_instance.teammate_review_allowed_id,
              type: 'TopicDueDate'
            )
  end
  class DeleteSignupAction

    def set_error_if_work_submitted
      raise NotImplementedError
    end

    def set_error_if_deadline_passed
      raise NotImplementedError
    end

    def delete_signup_for_topic(assignment_id, topic_id, user_id)
      raise NotImplementedError
    end

    def set_success_message_after_delete
      raise NotImplementedError
    end
  end
  
  class InstructorDeleteSignupAction < DeleteSignupAction

    def set_error_if_work_submitted
      return 'The student has already submitted their work, so you are not allowed to remove them.'
    end
    
    def set_error_if_deadline_passed
        return 'You cannot drop a student after the drop topic deadline!'
    end
    
    def delete_signup_for_topic(assignment_id, topic_id, user_id)
      SignUpTopic.reassign_topic(user_id, assignment_id, topic_id)
    end

    def set_success_message_after_delete
      return 'You have successfully dropped the student from the topic.'
    end
  end

  class StudentDeleteSignupAction < DeleteSignupAction

    def set_error_if_work_submitted
      return 'You have already submitted your work, so you are not allowed to drop your topic.'
    end
    
    def set_error_if_deadline_passed
      return 'You cannot drop your topic after the drop topic deadline!'
    end

    def delete_signup_for_topic(assignment_id, topic_id, user_id)
      SignUpTopic.reassign_topic(user_id, assignment_id, topic_id)
    end

    def set_success_message_after_delete
      return 'You have successfully dropped your topic.'
    end
  end

end
