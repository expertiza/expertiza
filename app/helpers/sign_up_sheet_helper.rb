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

  #to fetch assignment details
  def fetch_assignment_details(participant)
    @assignment = participant.assignment
    @slots_filled = SignUpTopic.find_slots_filled(@assignment.id)
    @slots_waitlisted = SignUpTopic.find_slots_waitlisted(@assignment.id)
    @sign_up_topics = SignUpTopic.where(assignment_id: @assignment.id, private_to: nil)
    @max_team_size = @assignment.max_team_size
    @use_bookmark = @assignment.use_bookmark
  end
  
  def fetch_deadlines(assignment)
    @signup_topic_deadline = assignment.due_dates.find_by(deadline_type_id: 7)
    @drop_topic_deadline = assignment.due_dates.find_by(deadline_type_id: 6)
  end
  
  def set_action_display_status(assignment)
    # Determine if the user is allowed to perform an action based on the signup deadline
    signup_deadline = assignment.due_dates.find_by(deadline_type_id: 1)
    return true if signup_deadline.nil?
    !assignment.staggered_deadline? && (signup_deadline.due_at < Time.now)
  end
  
  def user_sign_up_status(assignment, user_id)
    users_team = Team.find_team_users(assignment.id, user_id)
    if users_team.empty?
      @user_signup_status = nil
    else
      @user_signup_status = SignedUpTeam.find_user_signup_topics(assignment.id, users_team.first.t_id)
    end
  end
  
end

  def extract_due_dates(assignment, deadline_type_id)
    assignment.due_dates.select { |due_date| due_date.deadline_type_id == deadline_type_id }.map { |due_date| format_due_date(due_date.due_at) }
  end

  def format_due_date(due_at)
    DateTime.parse(due_at.to_s).strftime('%Y-%m-%d %H:%M')
  end

  def process_topic_deadline(topic, round, deadline_type, due_dates, assignment_due_dates)
    topic_due_date_key = "#{topic.id}_#{deadline_type}_#{round}_due_date"
    topic_due_date = due_dates[topic_due_date_key]
    assignment_due_date = assignment_due_dates[deadline_type.to_sym][round - 1]

    return if topic_due_date == assignment_due_date

    deadline_type_id = DeadlineType.find_by_name(deadline_type).id
    topic_due_date_record = TopicDueDate.where(
      parent_id: topic.id,
      deadline_type_id: deadline_type_id,
      round: round
    ).first_or_initialize
  
    save_or_update_deadline(topic_due_date_record, topic_due_date, assignment_due_dates, deadline_type, round)

  end



  def save_or_update_deadline(record, topic_due_date, assignment_due_dates, deadline_type, round)
    assignment_due_date_details = instance_variable_get('@assignment_' + deadline_type + '_due_dates')[round - 1].submission_allowed_id
#assignment_due_dates[deadline_type.to_sym][round - 1]
    puts assignment_due_date_details 

    attributes = {
      due_at: topic_due_date,
      submission_allowed_id: assignment_due_date_details.submission_allowed_id,
      review_allowed_id: assignment_due_date_details.review_allowed_id,
      review_of_review_allowed_id: assignment_due_date_details.review_of_review_allowed_id,
      quiz_allowed_id: assignment_due_date_details.quiz_allowed_id,
      teammate_review_allowed_id: assignment_due_date_details.teammate_review_allowed_id,
      round: round,
      flag: assignment_due_date_details.flag,
      threshold: assignment_due_date_details.threshold,
      delayed_job_id: assignment_due_date_details.delayed_job_id,
      deadline_name: assignment_due_date_details.deadline_name,
      description_url: assignment_due_date_details.description_url,
      type: 'TopicDueDate'
    }
    record.update(attributes)
  end

  def fetch_assignment_due_dates(assignment)
    submission_due_dates = assignment.due_dates.select { |due_date| due_date.deadline_type_id == 1 }
    review_due_dates = assignment.due_dates.select { |due_date| due_date.deadline_type_id == 2 }
   [submission_due_dates, review_due_dates]
  end

  def process_due_dates_for_topic_and_round(topic, round, due_dates)
   %w[submission review].each do |deadline_type|
    topic_due_date = due_dates["#{topic.id}_#{deadline_type}_#{round}_due_date"]
    assignment_due_date = @assignment_submission_due_dates if deadline_type == 'submission'
    assignment_due_date ||= @assignment_review_due_dates
    current_due_date = assignment_due_date[round - 1]
    next if topic_due_date == current_due_date.due_at.strftime('%Y-%m-%d %H:%M')
    deadline_type_id = DeadlineType.find_by_name(deadline_type).id
    existing_due_date = TopicDueDate.find_by(parent_id: topic.id, deadline_type_id: deadline_type_id, round: round)
    if existing_due_date
      update_topic_due_date(existing_due_date, current_due_date, topic_due_date)
    else
      create_topic_due_date(topic, current_due_date, deadline_type_id, round, topic_due_date)
    end
  end
 end



  def create_topic_due_date(topic, assignment_due_date, deadline_type_id, round, topic_due_date)
    TopicDueDate.create(
      due_at: topic_due_date,
      deadline_type_id: deadline_type_id,
      parent_id: topic.id,
      submission_allowed_id: assignment_due_date.submission_allowed_id,
      review_allowed_id: assignment_due_date.review_allowed_id,
      review_of_review_allowed_id: assignment_due_date.review_of_review_allowed_id,
      quiz_allowed_id: assignment_due_date.quiz_allowed_id,
      teammate_review_allowed_id: assignment_due_date.teammate_review_allowed_id,
      flag: assignment_due_date.flag,
      threshold: assignment_due_date.threshold,
      delayed_job_id: assignment_due_date.delayed_job_id,
      deadline_name: assignment_due_date.deadline_name,
      description_url: assignment_due_date.description_url,
      round: round,
      type: 'TopicDueDate'
    )
  end



  def update_topic_due_date(existing_due_date, assignment_due_date, topic_due_date)
    existing_due_date.update(
      due_at: topic_due_date,
      submission_allowed_id: assignment_due_date.submission_allowed_id,
      review_allowed_id: assignment_due_date.review_allowed_id,
      review_of_review_allowed_id: assignment_due_date.review_of_review_allowed_id,
      quiz_allowed_id: assignment_due_date.quiz_allowed_id,
      teammate_review_allowed_id: assignment_due_date.teammate_review_allowed_id
   )
 end
