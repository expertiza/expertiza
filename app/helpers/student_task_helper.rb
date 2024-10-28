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

  def populate_timeline_from(model_class, participant_id, label_lamda, timeline_list)
    model_class.where(reviewer_id: participant_id).find_each do |rm|
      response = Response.where(map_id: rm.id).last
      next if response.nil?

      timeline = {
        id: response.id,
        label: label_lamda.call(response),
        updated_at: response.updated_at.strftime('%a, %d %b %Y %H:%M')
      }

      timeline_list << timeline
    end
  end

  def update_timeline_with_peer_reviews(participant_id, timeline_list)
    populate_timeline_from(ReviewResponseMap, participant_id, ->(response) { ('Round ' + response.round.to_s + ' Peer Review').humanize }, timeline_list)
  end

  def update_timeline_with_author_feedbacks(participant_id, timeline_list)
    populate_timeline_from(FeedbackResponseMap, participant_id, ->(_response) { 'Author feedback' }, timeline_list)
  end

  def update_timeline_with_assignment_deadlines(assignment, timeline_list)
    assignment.due_dates.each do |dd|
      timeline = { label: (dd.deadline_type.name + ' Deadline').humanize }
      unless dd.due_at.nil?
        timeline[:updated_at] = dd.due_at.strftime('%a, %d %b %Y %H:%M')
        timeline_list << timeline
      end
    end
  end

  def generate_timeline(assignment, participant)
    timeline_list = []
    update_timeline_with_assignment_deadlines(assignment, timeline_list)
    update_timeline_with_peer_reviews(participant.get_reviewer.try(:id), timeline_list)
    update_timeline_with_author_feedbacks(participant.try(:id), timeline_list)
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
end
