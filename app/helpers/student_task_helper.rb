module StudentTaskHelper
  TIME_FORMAT = '%a, %d %b %Y %H:%M'.freeze

  # Retrieves review grade information for a given participant, including score and comments if available;
  # returns a formatted string with grade and comment as a tooltip, or 'N/A' if no grade or comment is present.
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

  # Determines if there are any topics in an assignment that are available for review, based on the current stage
  # and return true if review, metareview, etc.. is allowed.
  def check_reviewable_topics(assignment)
    return true if !assignment.topics? && (assignment.current_stage != 'submission')

    sign_up_topics = SignUpTopic.where(assignment_id: assignment.id)
    sign_up_topics.each { |topic| return true if assignment.can_review(topic.id) }
    false
  end

  # Checks if a self-review for the given participant ID has been submitted,
  # returning false if unsubmitted, or true otherwise.
  def unsubmitted_self_review?(participant_id)
    self_review = SelfReviewResponseMap.where(reviewer_id: participant_id).first.try(:response).try(:last)
    return !self_review.try(:is_submitted) if self_review

    true
  end

  # Retrieves HTML content displaying badges awarded to the participant,
  # showing only those badges that are approved.
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

  # Checks if the assignment has a review deadline set by locating any due dates with the type 'review'.
  def review_deadline?(assignment)
    assignment.find_due_dates('review').present?
  end

  # Iterates through each due date of an assignment and yields each date
  # to a provided block unless the due date is nil.
  def for_each_due_date_of_assignment(assignment)
    assignment.due_dates.each do |dd|
      yield dd unless dd.due_at.nil?
    end
  end

  # Iterates through each peer review for a participant,
  # yielding each review to a provided block.
  def for_each_peer_review(participant_id, &block)
    fetch_response_from(ReviewResponseMap, participant_id, &block)
  end

  # Iterates through each author feedback response for a participant,
  # yielding each response to a provided block.
  def for_each_author_feedback(participant_id, &block)
    fetch_response_from(FeedbackResponseMap, participant_id, &block)
  end

  # Generates a timeline of events related to the assignment for the participant,
  # including due dates, peer reviews, and author feedback, sorted by their update time.
  def generate_timeline(assignment, participant)
    [].concat(generate_due_date_timeline(assignment))
      .concat(generate_peer_review_timeline(participant))
      .concat(generate_author_feedback_timeline(participant))
      .sort_by { |f| Time.zone.parse f[:updated_at] }
  end

  # Creates a StudentTask instance for a given participant.
  def create_student_task_for_participant(participant)
    StudentTask.new(
      participant: participant,
      assignment: participant.assignment,
      topic: participant.topic,
      current_stage: participant.current_stage,
      stage_deadline: parse_stage_deadline(participant.stage_deadline)
    )
  end

  # Retrieves tasks associated with a user by iterating over the user's
  # assignment participants and sorting them by their stage deadlines.
  def retrieve_tasks_for_user(user)
    user.assignment_participants.includes(%i[assignment topic]).map do |participant|
      create_student_task_for_participant participant
    end.sort_by(&:stage_deadline)
  end

  # Parses a stage deadline string to a Time object; defaults to one year in the future if parsing fails.
  def parse_stage_deadline(part)
    Time.parse(part)
  rescue StandardError
    Time.now + 1.year
  end

  # Determines if the given team is associated with a calibration assignment.
  def calibration_assignment?(team)
    Assignment.find_by(id: team.parent_id).is_calibrated
  end

  # Retrieves the course ID for the assignment to which the given team belongs.
  def course_id_for_team(team)
    Assignment.find_by(id: team.parent_id).course_id
  end

  # Retrieves an array of names of teammates in a given team, excluding the current user
  def teammate_names_for_team(team, user, ip_address)
    Team.find(team.id).participants
        .reject { |p| p.name == user.name }
        .map { |p| p.user.fullname(ip_address) }
  end

  # Validates if the given team is an assignment team and is not related to a calibration assignment.
  def valid_assignment_team?(team)
    team.is_a?(AssignmentTeam) && !calibration_assignment?(team)
  end

  # Retrieves tuple of the course ID and teammate names for a given team;
  # returns both only if teammate names exist.
  def get_course_id_and_teammate_names_for_team(team, user, ip_address)
    course_id = course_id_for_team(team)
    teammate_names = teammate_names_for_team(team, user, ip_address)
    return [course_id, teammate_names] if teammate_names && !teammate_names.empty?
  end

  # Iterates through each valid assignment team of a user and yields course ID and teammate names for each team.
  def for_teammates_in_each_team_of_user(user, ip_address = nil)
    user.teams.each do |team|
      if valid_assignment_team?(team)
        result = get_course_id_and_teammate_names_for_team(team, user, ip_address)
        yield(result) if result
      end
    end
  end

  # Groups teammates by course for a user and returns a hash where keys are course IDs
  # and values are lists of teammate names.
  def group_teammates_by_course_for_user(user, ip_address = nil)
    students_teamed = {}
    for_teammates_in_each_team_of_user(user, ip_address) do |course_id, teammate_names|
      students_teamed[course_id] ||= []
      students_teamed[course_id].concat(teammate_names).uniq!
    end
    students_teamed
  end

  private

  # Maps elements from a data source using a parser, and returns an array of parsed results.
  def map_with_parser(fn, data, parser)
    result = []
    fn.call(data) do |elem|
      result << parser.call(elem)
    end
    result
  end

  # Formats a due date object as a timeline entry hash with a human-readable label and formatted update time.
  def parse_due_date_to_timeline(due_date)
    {
      label: (due_date.deadline_type.name + ' Deadline').humanize,
      updated_at: due_date.due_at.strftime(TIME_FORMAT)
    }
  end

  # Formats a response object as a timeline entry hash with a given label and formatted update time.
  def parse_response_to_timeline(response, label)
    {
      id: response.id,
      label: label,
      updated_at: response.updated_at.strftime(TIME_FORMAT)
    }
  end

  # Generates a timeline of due dates for an assignment by mapping each due date through a parsing function.
  def generate_due_date_timeline(assignment)
    map_with_parser(
      method(:for_each_due_date_of_assignment),
      assignment,
      ->(due_date) { parse_due_date_to_timeline(due_date) }
    )
  end

  # Generates a timeline of peer reviews for a participant by mapping
  # each review response through a parsing function.
  def generate_peer_review_timeline(participant)
    map_with_parser(
      method(:for_each_peer_review),
      participant.get_reviewer.try(:id),
      ->(response) { parse_response_to_timeline(response, "Round #{response.round} Peer Review".humanize) }
    )
  end

  # Generates a timeline of author feedback for a participant by mapping
  # each feedback response through a parsing function.
  def generate_author_feedback_timeline(participant)
    map_with_parser(
      method(:for_each_author_feedback),
      participant.try(:id),
      ->(response) { parse_response_to_timeline(response, 'Author feedback') }
    )
  end

  # Fetches the latest response from a specific model class (ReviewResponseMap or FeedbackResponseMap)
  # for a participant, yielding each response to a provided block.
  def fetch_response_from(model_class, participant_id)
    model_class.where(reviewer_id: participant_id).find_each do |rm|
      response = Response.where(map_id: rm.id).last
      yield response unless response.nil?
    end
  end
end
