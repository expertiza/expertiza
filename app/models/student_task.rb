# Author: Andrew Kofink, 2013-09-28
class StudentTask
  include ActionView::Helpers::DateHelper
  include StudentTaskHelper
  attr_accessor :assignment, :current_stage, :participant, :stage_deadline, :topic

  delegate :course, to: :assignment
  delegate :topic, to: :participant
  delegate :response_maps, to: :participant

  def initialize(args)
    @assignment = args[:assignment]
    @current_stage = args[:current_stage]
    @participant = args[:participant]
    @stage_deadline = args[:stage_deadline]
    @topic = args[:topic]
  end

  def topic_name
    topic.try(:topic_name) || '-'
  end

  def complete?
    stage_deadline == 'Complete'
  end

  def content_submitted_in_current_stage?
    current_stage == 'submission' && (hyperlinks.present? || recent_submission.present?) 
  end

  def hyperlinks
    @hyperlinks ||= participant.team.nil? ? [] : participant.team.hyperlinks
  end

  def recent_submission
    participant.team&.most_recent_submission
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

  def relative_deadline
    time_ago_in_words(stage_deadline) if stage_deadline
  end

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

  def self.find_teammates_by_user(user, ip_address = nil)
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
