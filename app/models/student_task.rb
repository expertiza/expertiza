# Author: Andrew Kofink, 2013-09-28
class StudentTask
  attr_accessor :assignment, :current_stage, :participant, :stage_deadline, :topic

  def initialize(args)
    @assignment = args[:assignment]
    @current_stage = args[:current_stage]
    @participant = args[:participant]
    @stage_deadline = args[:stage_deadline]
    @topic = args[:topic]
  end

  def self.from_participant(participant)
    StudentTask.new(
      participant: participant,
      assignment: participant.assignment,
      topic: participant.topic,
      current_stage: participant.current_stage,
      stage_deadline: (begin
                         Time.parse(participant.stage_deadline)
                       rescue StandardError
                         Time.now + 1.year
                       end)
    )
  end

  def self.from_participant_id(id)
    from_participant(AssignmentParticipant.find_by(id: id))
  end

  def self.from_user(user)
    user.assignment_participants.includes(%i[assignment topic]).map do |participant|
      StudentTask.from_participant participant
    end.sort_by(&:stage_deadline)
  end

  def topic_name
    topic.try(:topic_name) || '-'
  end

  def complete?
    stage_deadline == 'Complete'
  end

  def content_submitted_in_current_stage?
    current_stage == 'submission' && hyperlinks.present?
  end

  delegate :course, to: :assignment

  def hyperlinks
    @hyperlinks ||= participant.team.nil? ? [] : participant.team.hyperlinks
  end

  def incomplete?
    !complete?
  end

  def metareviews_given?
    response_maps.inject(nil) { |i, j| i || (j.response && j.class.to_s[/Metareview/]) }
  end

  def metareviews_given_in_current_stage?
    current_stage == 'metareview' && metareviews_given?
  end

  def not_started?
    in_work_stage? && !started?
  end

  include ActionView::Helpers::DateHelper
  def relative_deadline
    time_ago_in_words(stage_deadline) if stage_deadline
  end

  delegate :response_maps, to: :participant

  def reviews_given?
    response_maps.inject(nil) { |i, j| i || (j.response && j.class.to_s[/Review/]) }
  end

  def reviews_given_in_current_stage?
    current_stage == 'review' && reviews_given?
  end

  def in_work_stage?
    current_stage == 'submission' ||
      current_stage == 'review' ||
      current_stage == 'metareview'
  end

  def revision?
    content_submitted_in_current_stage? ||
      reviews_given_in_current_stage? ||
      metareviews_given_in_current_stage?
  end

  def started?
    @started ||= incomplete? && revision?
  end

  delegate :topic, to: :participant

  def self.teamed_students(user, ip_address = nil)
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

  def self.get_due_date_data(assignment, timeline_list)
    assignment.due_dates.each do |dd|
      timeline = { label: (dd.deadline_type.name + ' Deadline').humanize }
      unless dd.due_at.nil?
        timeline[:updated_at] = dd.due_at.strftime('%a, %d %b %Y %H:%M')
        timeline_list << timeline
      end
    end
  end

  def self.get_submission_data(assignment_id, team_id, timeline_list)
    SubmissionRecord.where(team_id: team_id, assignment_id: assignment_id).find_each do |sr|
      timeline = {
        label: sr.operation.humanize,
        updated_at: sr.updated_at.strftime('%a, %d %b %Y %H:%M')
      }
      timeline[:link] = sr.content if sr.operation == 'Submit Hyperlink' || sr.operation == 'Remove Hyperlink'
      timeline_list << timeline
    end
  end

  def self.get_peer_review_data(participant_id, timeline_list)
    ReviewResponseMap.where(reviewer_id: participant_id).find_each do |rm|
      response = Response.where(map_id: rm.id).last
      next if response.nil?

      timeline = {
        id: response.id,
        label: ('Round ' + response.round.to_s + ' Peer Review').humanize,
        updated_at: response.updated_at.strftime('%a, %d %b %Y %H:%M')
      }
      timeline_list << timeline
    end
  end

  def self.get_author_feedback_data(participant_id, timeline_list)
    FeedbackResponseMap.where(reviewer_id: participant_id).find_each do |rm|
      response = Response.where(map_id: rm.id).last
      next if response.nil?

      timeline = {
        id: response.id,
        label: 'Author feedback',
        updated_at: response.updated_at.strftime('%a, %d %b %Y %H:%M')
      }
      timeline_list << timeline
    end
  end

  # static method for the building timeline data
  def self.get_timeline_data(assignment, participant, _team)
    timeline_list = []
    get_due_date_data(assignment, timeline_list)
    # get_submission_data(assignment.try(:id), team.try(:id), timeline_list)
    get_peer_review_data(participant.get_reviewer.try(:id), timeline_list)
    get_author_feedback_data(participant.try(:id), timeline_list)
    timeline_list.sort_by { |f| Time.zone.parse f[:updated_at] }
  end
end
