module StudentTaskHelper
  TIME_FORMAT = '%a, %d %b %Y %H:%M'.freeze

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

  def for_each_peer_review(participant_id, &block)
    fetch_response_from(ReviewResponseMap, participant_id, &block)
  end

  def for_each_author_feedback(participant_id, &block)
    fetch_response_from(FeedbackResponseMap, participant_id, &block)
  end

  def generate_timeline(assignment, participant)
    [].concat(generate_due_date_timeline(assignment))
      .concat(generate_peer_review_timeline(participant))
      .concat(generate_author_feedback_timeline(participant))
      .sort_by { |f| Time.zone.parse f[:updated_at] }
  end

  def create_student_task_for_participant(participant)
    StudentTask.new(
      participant: participant,
      assignment: participant.assignment,
      topic: participant.topic,
      current_stage: participant.current_stage,
      stage_deadline: parse_stage_deadline(participant.stage_deadline)
    )
  end

  def retrieve_tasks_for_user(user)
    user.assignment_participants.includes(%i[assignment topic]).map do |participant|
      create_student_task_for_participant participant
    end.sort_by(&:stage_deadline)
  end

  def parse_stage_deadline(part)
    Time.parse(part)
  rescue StandardError
    Time.now + 1.year
  end

  def calibration_assignment?(team)
    Assignment.find_by(id: team.parent_id).is_calibrated
  end

  def course_id_for_team(team)
    Assignment.find_by(id: team.parent_id).course_id
  end

  def teammate_names_for_team(team, user, ip_address)
    Team.find(team.id).participants
        .reject { |p| p.name == user.name }
        .map { |p| p.user.fullname(ip_address) }
  end

  def valid_assignment_team?(team)
    # Teammates not in an assignment or in calibration assignment should not be counted in teaming requirement.
    team.is_a?(AssignmentTeam) && !calibration_assignment?(team)
  end

  def for_teammates_in_each_team_of_user(user, ip_address = nil)
    user.teams.each do |team|
      next unless valid_assignment_team?(team)
      course_id = course_id_for_team(team)
      teammate_names = teammate_names_for_team(team, user, ip_address)
      yield(course_id, teammate_names) unless teammate_names.nil? || teammate_names.empty?
    end
  end

  def group_teammates_by_course_for_user(user, ip_address = nil)
    students_teamed = {}
    for_teammates_in_each_team_of_user(user, ip_address) do |course_id, teammate_names|
      students_teamed[course_id] ||= []
      students_teamed[course_id].concat(teammate_names).uniq!
    end
    students_teamed
  end

  private

  def map_with_parser(fn, data, parser)
    result = []
    fn.call(data) do |elem|
      result << parser.call(elem)
    end
    result
  end

  def parse_due_date_to_timeline(due_date)
    {
      label: (due_date.deadline_type.name + ' Deadline').humanize,
      updated_at: due_date.due_at.strftime(TIME_FORMAT)
    }
  end
  
  def parse_response_to_timeline(response, label)
    {
      id: response.id,
      label: label,
      updated_at: response.updated_at.strftime(TIME_FORMAT)
    }
  end

  def generate_due_date_timeline(assignment)
    map_with_parser(
      method(:for_each_due_date_of_assignment),
      assignment,
      ->(due_date) { parse_due_date_to_timeline(due_date) }
    )
  end

  def generate_peer_review_timeline(participant_id)
    map_with_parser(
      method(:for_each_peer_review),
      participant_id,
      ->(response) { parse_response_to_timeline(response, "Round #{response.round} Peer Review".humanize) }
    )
  end

  def generate_author_feedback_timeline(participant_id)
    map_with_parser(
      method(:for_each_author_feedback),
      participant_id,
      ->(response) { parse_response_to_timeline(response, 'Author feedback') }
    )
  end

  def fetch_response_from(model_class, participant_id)
    model_class.where(reviewer_id: participant_id).find_each do |rm|
      response = Response.where(map_id: rm.id).last
      yield response unless response.nil?
    end
  end
end
