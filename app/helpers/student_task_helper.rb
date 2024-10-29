module StudentTaskHelper
  def get_review_grade_info(participant)
    if participant.try(:review_grade).try(:grade_for_reviewer).nil? ||
       participant.try(:review_grade).try(:comment_for_reviewer).nil?
      result = 'N/A'
    else
      info = 'Score: ' + participant.try(:review_grade).try(:grade_for_reviewer).to_s + "/100\n"
      info += 'Comment: ' + participant.try(:review_grade).try(:comment_for_reviewer).to_s
      info = truncate(info, length: 1500, omission: '...')
      result = "<img src = '/assets/info.png' title = '" + info + "'>"
    end
    result.html_safe
  end

  def check_reviewable_topics(assignment)
    return true if !assignment.topics? && (assignment.current_stage != 'submission')

    sign_up_topics = SignUpTopic.where(assignment_id: assignment.id)
    sign_up_topics.each { |topic| return true if assignment.can_review(topic.id) }
    false
  end

  def unsubmitted_self_review?(participant_id)
    self_review = SelfReviewResponseMap.where(reviewer_id: participant_id).first.try(:response).try(:last)
    return !self_review.try(:is_submitted) if self_review

    true
  end

  def get_awarded_badges(participant)
    info = ''
    participant.awarded_badges.each do |awarded_badge|
      badge = awarded_badge.badge
      # In the student task homepage, list only those badges that are approved
      if awarded_badge.approved?
        info += '<img width="30px" src="/assets/badges/' + badge.image_name + '" title="' + badge.name + '" />'
      end
    end
    info.html_safe
  end

  def review_deadline?(assignment)
    assignment.find_due_dates('review').present?
  end

  def for_each_due_date_of_assignment(assignment)
    assignment.due_dates.each do |dd|
      yield dd unless dd.due_at.nil?
    end
  end

  def fetch_response_from(model_class, participant_id)
    model_class.where(reviewer_id: participant_id).find_each do |rm|
      response = Response.where(map_id: rm.id).last
      yield response unless response.nil?
    end
  end

  def for_each_peer_review(participant_id, &block)
    fetch_response_from(ReviewResponseMap, participant_id, &block)
  end

  def for_each_author_feedback(participant_id, &block)
    fetch_response_from(FeedbackResponseMap, participant_id, &block)
  end

  def generate_timeline(assignment, participant)

    due_date_modifier = ->(dd) {
      { label: (dd.deadline_type.name + ' Deadline').humanize,
        updated_at: dd.due_at.strftime('%a, %d %b %Y %H:%M')
      }
    }

    response_modifier = ->(response, label) {
      {
        id: response.id,
        label: label,
        updated_at: response.updated_at.strftime('%a, %d %b %Y %H:%M')
      }
    }

    timeline_list = []

    for_each_due_date_of_assignment(assignment) do |due_date|
      timeline_list << due_date_modifier.call(due_date)
    end
    
    for_each_peer_review(participant.get_reviewer.try(:id)) do |response|
      timeline_list << response_modifier.call(response, "Round #{response.round} Peer Review".humanize)
    end

    for_each_author_feedback(participant.try(:id)) do |response|
      timeline_list << response_modifier.call(response, "Author feedback")
    end
    
    timeline_list.sort_by { |f| Time.zone.parse f[:updated_at] }
  end

  def create_student_task_for_participant(participant)
    StudentTask.new(
      participant: participant,
      assignment: participant.assignment,
      topic: participant.topic,
      current_stage: participant.current_stage,
      stage_deadline: get_stage_deadline(participant.stage_deadline)
    )
  end

  def retrieve_tasks_for_user(user)
    user.assignment_participants.includes(%i[assignment topic]).map do |participant|
      create_student_task_for_participant participant
    end.sort_by(&:stage_deadline)
  end

  def get_stage_deadline(part)
    Time.parse(part)
  rescue StandardError
    Time.now + 1.year
  end

  def find_teammates_by_user(user, ip_address = nil)
    students_teamed = {}
    user.teams.each do |team|
      next unless team.is_a?(AssignmentTeam)
      # Teammates in calibration assignment should not be counted in teaming requirement.
      next if Assignment.find_by(id: team.parent_id).is_calibrated

      teammates = []
      course_id = Assignment.find_by(id: team.parent_id).course_id
      team_participants = Team.find(team.id).participants.reject { |p| p.name == user.name }
      team_participants.each { |p| teammates << p.user.fullname(ip_address) }
      next if teammates.empty?

      if students_teamed[course_id].nil?
        students_teamed[course_id] = teammates
      else
        teammates.each { |teammate| students_teamed[course_id] << teammate }
      end
      students_teamed[course_id].uniq! if students_teamed.key?(course_id)
    end
    students_teamed
  end
end
