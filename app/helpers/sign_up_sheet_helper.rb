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
    teams_users_array = Array.new
    teams_users.each do |teams_user|
      teams_users_array << teams_user.user_id
    end
    @suggested_topics = SignUpTopic.where(assignment_id: assignment_id, private_to: teams_users_array)
  end

  # Render topic row for intelligent topic selection.
  def get_intelligent_topic_row(topic, selected_topics)
    row_html = ''
    if !selected_topics.nil? && selected_topics.size != 0
      for selected_topic in @selected_topics
        if selected_topic.topic_id == topic.id and !selected_topic.is_waitlisted
          row_html = '<tr bgcolor="yellow">'
        elsif selected_topic.topic_id == topic.id and selected_topic.is_waitlisted
          row_html = '<tr bgcolor="lightgray">'
        else
          row_html = '<tr id="topic_"' + topic.id.to_s + '>'
        end
      end
    else
      row_html = '<tr id="topic_"' + topic.id.to_s + ' style="background-color:' + get_topic_bg_color(topic) + '">'
    end
    row_html.html_safe
  end


  # Compute background colour for a topic with respect to maximum team size.
  def get_topic_bg_color(topic)
    'rgb(' + (400*(1-(Math.tanh(2*[@max_team_size.to_f/Bid.where(topic_id:topic.id).count,1].min-1)+1)/2))
        .to_i.to_s + ',' + (400*(Math.tanh(2*[@max_team_size.to_f/Bid.where(topic_id:topic.id).
        count,1].min-1)+1)/2).to_i.to_s + ',0)'
  end


  # Render the participant info for a topic and assignment.
  def render_participant_info(topic, assignment, participants)
    name_html = ''
    if !participants.nil? && participants.size > 0
      chooser_present = false
      for participant in @participants
        if topic.id == participant.topic_id
          chooser_present = true
          if assignment.max_team_size > 1
            name_html += '<br/><b>' + participant.team_name_placeholder + '</b><br/>'
          end
          name_html += 'participant.user_name_placeholder'
          if participant.is_waitlisted
            name_html += '<font color="red">(waitlisted)</font>'
          end
          name_html += '<br/>'
        end
      end
      unless chooser_present
        name_html += 'No choosers.'
      end
    end
    name_html.html_safe
  end

end
