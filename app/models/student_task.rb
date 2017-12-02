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
      stage_deadline: (Time.parse(participant.stage_deadline) rescue Time.now + 1.year)
    )
  end

  def self.from_participant_id(id)
    from_participant AssignmentParticipant.find(id)
  end

  def self.from_user(user)
    user.assignment_participants.map do |participant|
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
    current_stage == "submission" && hyperlinks.present?
  end

  delegate :course, to: :assignment

  def hyperlinks
    @hyperlinks ||= participant.team.nil? ? [] : participant.team.hyperlinks
  end

  def incomplete?
    !complete?
  end

  def metareviews_given?
    response_maps.inject(nil) {|i, j| i || (j.response && j.class.to_s[/Metareview/]) }
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
    response_maps.inject(nil) {|i, j| i || (j.response && j.class.to_s[/Review/]) }
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
    @started ||= incomplete? &&
      (content_submitted_in_current_stage? ||
       reviews_given_in_current_stage? ||
       metareviews_given_in_current_stage?)
  end

  delegate :topic, to: :participant

  def self.teamed_students(user)
    @students_teamed = {} # {|h,k| h[k] = Hash.new(&h.default_proc)}
    @teammates = []
    @teams = user.teams

    @teams.each do |team|
      next unless team.is_a?(AssignmentTeam)
      # Teammates in calibration assignment should not be counted in teaming requirement.
      next if Assignment.find(team.parent_id).is_calibrated
      @teammates = []
      @course_id = Assignment.find(team.parent_id).course_id
      @team_participants = Team.find(team.id).participants
      @team_participants = @team_participants.select {|participant| participant.name != user.name }
      @team_participants.each do |t|
        u = User.find(t.user_id)
        @teammates << u.fullname
      end
      next if @teammates.empty?
      if @students_teamed[@course_id].nil?
        @students_teamed[@course_id] = @teammates
      else
        @teammates.each {|teammate| @students_teamed[@course_id] << teammate }
        end
      @students_teamed[@course_id].uniq! if @students_teamed.key?(@course_id)
    end
    @students_teamed
  end

  #Assignment due dates data
  def self.get_duedate_data(assignment_id, timeline_list)
    @dues = DueDate.where(parent_id: assignment_id)
    @dues.each do |dd|
      tmp = Hash.new
      tmp[:label] = dd.deadline_type.name + ' Deadline'
      tmp[:link] = nil
      unless dd.due_at.nil?
        tmp[:updated_at] = dd.due_at.strftime('%a, %d %b %Y %H:%M:%S')
        @timeline_list << tmp
      end
    end
  end

  #submitted links and file data
  def self.get_submission_data(assignment_id, team_id, timeline_list)
    @submissions = SubmissionRecord.where(team_id: team_id , assignment_id: assignment_id)
    @submissions.each do |sr|
      tmp = Hash.new
      tmp[:label] = sr.operation
      tmp[:updated_at] = sr.updated_at.strftime('%a, %d %b %Y %H:%M:%S')
      unless sr.operation == 'Submit File' || sr.operation == 'Remove File'
        tmp[:link] = sr.content
      end
      @timeline_list << tmp
    end
  end

  #assignment review data
  def self.get_review_data(participant_id, timeline_list)
    @response_map = ResponseMap.where(reviewer_id: participant_id)
    @response_map.each do |rm|
      tmp = Hash.new
      @response = Response.where(map_id: rm.id)
      unless @response[0].nil?
        tmp[:label] = 'Round ' + @response[0].round.to_s + ' Review'
        tmp[:updated_at] = @response[0].updated_at.strftime('%a, %d %b %Y %H:%M:%S')
        tmp[:id] = @response[0].id
        @timeline_list << tmp
      end
    end
  end

  #static method for the building timeline data
  def self.get_timeline_data(assignment_id, participant_id, team_id)
    @timeline_list = Array.new
    #Assignment duedate data
    get_duedate_data(assignment_id, @timeline_list)
    #Studnet's link and file submissions
    get_submission_data(assignment_id, team_id, @timeline_list)
    #Student's assignment review performed
    get_review_data(participant_id, @timeline_list)
    #List is sorted and returned
    return @timeline_list.sort_by{ |f| Time.parse f[:updated_at]}
  end
end
