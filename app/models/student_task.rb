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
      :participant => participant,
      :assignment => participant.assignment,
      :topic => participant.topic,
      :current_stage => participant.current_stage,
      :stage_deadline => (Time.parse(participant.stage_deadline) rescue Time.now + 1.years)
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
    (current_stage == "submission" || current_stage == "resubmission") &&
      (participant.resubmission_times.size > 0 || hyperlinks.present?)
  end

  def course
    assignment.course
  end

  def hyperlinks
    @hyperlinks ||= participant.hyperlinks
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

  def response_maps
    participant.response_maps
  end

  def reviews_given?
    response_maps.inject(nil) { |i, j| i || (j.response && j.class.to_s[/Review/]) }
  end

  def reviews_given_in_current_stage?
    current_stage == 'review' || current_stage == 'rereview' && reviews_given?
  end

  def in_work_stage?
    current_stage == 'submission' ||
      current_stage == 'resubmission' ||
      current_stage == 'review' ||
      current_stage == 'rereview' ||
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

  def topic
    participant.topic
  end

  def self.teamed_students(user)

        @students_teamed = Hash.new #{|h,k| h[k] = Hash.new(&h.default_proc)}
        @teammates = Array.new
        @teams = user.teams
         
         @teams.each do |team|
             @teammates  = []
             @course_id = Assignment.find(team.parent_id).course_id
             @team_participants = Team.find(team.id).participants
             @team_participants = @team_participants.select {|participant| participant.name != user.name}
             @team_participants.each{ |t|
                 u = Student.find(t.user_id)
                 @teammates << u.fullname
             }
             if !@teammates.empty?
                 if @students_teamed[@course_id].nil?
                    @students_teamed[@course_id] = @teammates
                 else
                     @teammates.each do |teammate| @students_teamed[@course_id] << teammate end
                 end
                 @students_teamed[@course_id].uniq! if @students_teamed.has_key?(@course_id)
             end
               
         end
        @students_teamed
  end
end
