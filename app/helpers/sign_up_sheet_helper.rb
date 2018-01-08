module SignUpSheetHelper
  # if the instructor does not specific the topic due date, it should be the same as assignment due date;
  # otherwise, it should display the topic due date.
  def check_topic_due_date_value(assignment_due_dates, topic_id, deadline_type_id = 1, review_round = 1)
    due_date = get_topic_deadline(assignment_due_dates, topic_id, deadline_type_id, review_round)
    DateTime.parse(due_date.to_s).strftime("%Y-%m-%d %H:%M").in_time_zone
  end

  def get_topic_deadline(assignment_due_dates, topic_id, deadline_type_id = 1, review_round = 1)
    topic_due_date = TopicDueDate.where(parent_id: topic_id,
                                        deadline_type_id: deadline_type_id,
                                        round: review_round).first rescue nil
    if !topic_due_date.nil?
      topic_due_date.due_at
    else
      assignment_due_dates[review_round - 1].due_at.to_s
    end
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
        row_html = if selected_topic.topic_id == topic.id and !selected_topic.is_waitlisted
                     '<tr bgcolor="yellow">'
                   elsif selected_topic.topic_id == topic.id and selected_topic.is_waitlisted
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
        chooser_present = true
        html += participant.user_name_placeholder
        if assignment.max_team_size > 1
          html += '<a href="/sign_up_sheet/delete_signup_as_instructor/' + participant.team_id.to_s + '?topic_id=' + topic.id.to_s + '"">'
          html += '<img border="0" align="middle" src="/assets/delete_icon.png" title="Drop Student"></a>'
        end
        html += '<font color="red">(waitlisted)</font>' if participant.is_waitlisted
        html += '<br/>'
      end
      html += 'No choosers.' unless chooser_present
    end
    html.html_safe
  end
end
