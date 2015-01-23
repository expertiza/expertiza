class AssignmentForm

  attr_accessor :assignment, :assignment_questionnaires, :due_dates

  DEFAULT_MAX_TEAM_SIZE = 1
  DEFAULT_WIKI_TYPE_ID = 1

  def initialize(args={})
    @assignment = Assignment.new(args[:assignment])
    if args[:assignment].nil?
      @assignment.course = Course.find(args[:parent_id]) if args[:parent_id]
      @assignment.instructor = @assignment.course.instructor if @assignment.course
      @assignment.wiki_type_id = DEFAULT_WIKI_TYPE_ID
      @assignment.max_team_size = DEFAULT_MAX_TEAM_SIZE
    end
    @assignment_questionnaires=Array(args[:assignment_questionnaires])
    @due_dates=Array(args[:due_dates])
  end

  #create a form object for this assignment_id
  def self.create_form_object(assignment_id)
    assignment_form = AssignmentForm.new
    assignment_form.assignment = Assignment.find(assignment_id)
    assignment_form.assignment_questionnaires = AssignmentQuestionnaire.where(assignment_id: assignment_id)
    assignment_form.due_dates = DueDate.where(assignment_id: assignment_id)
    assignment_form.set_up_assignment_review
    assignment_form
  end

  def update(attributes)
    @has_errors = false;
    has_late_policy = false;
    if attributes[:assignment][:late_policy_id].to_i > 0
      has_late_policy=true
    else
      attributes[:assignment][:late_policy_id] = nil
    end
    update_assignment(attributes[:assignment])
    update_assignment_questionnaires(attributes[:assignment_questionnaire])
    update_due_dates(attributes[:due_date])
    #delete the old queued items and recreate new ones if the assignment has late policy.
    if attributes[:due_date] and !@has_errors and has_late_policy
      delete_from_delayed_queue
      add_to_delayed_queue
    end
    !@has_errors;
  end

  alias update_attributes update

  #Code to update values of assignment
  def update_assignment(attributes)
    if !@assignment.update_attributes(attributes)
      @errors =@errors + @assignment.errors
      @has_errors = true;
    end
  end

  #code to save assignment questionnaires
  def update_assignment_questionnaires(attributes)
    existing_aqs = AssignmentQuestionnaire::where(assignment_id: @assignment.id)
    existing_aqs.each do |existing_aq|
      existing_aq.delete
    end
    attributes.each do |assignment_questionnaire|
      if assignment_questionnaire[:id].nil? or assignment_questionnaire[:id].blank?
        aq = AssignmentQuestionnaire.new(assignment_questionnaire)
        if !aq.save
          @errors =@errors + @assignment.errors
          @has_errors = true;
        end
      else
        aq = AssignmentQuestionnaire.find(assignment_questionnaire[:id])
        if !aq.update_attributes(assignment_questionnaire);
          @errors =@errors + @assignment.errors
          @has_errors = true;
        end
      end
      end
  end

  #code to save due dates
  def update_due_dates(attributes)
    attributes.each do |due_date|
      if due_date[:id].nil? or due_date[:id].blank?
        if due_date[:due_at].blank? then
          next
        end
        dd = DueDate.new(due_date)
        if !dd.save
          @errors =@errors + @assignment.errors
          @has_errors = true;
        end
      else
        dd = DueDate.find(due_date[:id])
        if !dd.update_attributes(due_date);
          @errors =@errors + @assignment.errors
          @has_errors = true;
        end
      end
    end
  end

  #Adds items to delayed_jobs queue for this assignment
  def add_to_delayed_queue
    duedates = DueDate::where(assignment_id: @assignment.id)
    duedates.each do |due_date|
      deadline_type = DeadlineType.find(due_date.deadline_type_id).name
      due_at = due_date.due_at.to_s(:db)
      Time.parse(due_at)
      due_at= Time.parse(due_at)
      mi=find_min_from_now(due_at)
      diff = mi-(due_date.threshold)*60
      if diff>0
        dj=Delayed::Job.enqueue(DelayedMailer.new(@assignment.id, deadline_type, due_date.due_at.to_s(:db)),
                                1, diff.minutes.from_now)
        due_date.update_attribute(:delayed_job_id, dj.id)
      end
    end
  end

  # Deletes the job with id equal to "delayed_job_id" from the delayed_jobs queue
  def delete_from_delayed_queue
    djobs = Delayed::Job.where(['handler LIKE "%assignment_id: ?%"', @assignment.id])
    for dj in djobs
      dj=Delayed::Job.find(delayed_job_id)
      if (dj != nil && dj.id != nil)
        dj.delete
      end
    end
  end

  def delete(force=nil)
        #delete from delayed_jobs queue related to this assignment
        delete_from_delayed_queue
        @assignment.delete(force)
  end
  # This functions finds the epoch time in seconds of the due_at parameter and finds the difference of it
  # from the current time and returns this difference in minutes
  def find_min_from_now(due_at)
    curr_time=DateTime.now.to_s(:db)
    curr_time=Time.parse(curr_time)
    time_in_min=((due_at - curr_time).to_i/60)
    time_in_min
  end

  #Save the assignment
  def save
    @assignment.save
  end
  #create a node for the assignment
  def create_assignment_node
    if !@assignment.nil?
     @assignment.create_node
    end
  end

  #NOTE: many of these functions actually belongs to other models
  #====setup methods for new and edit method=====#
  def set_up_assignment_review
    set_up_defaults

    submissions = @assignment.find_due_dates('submission') + @assignment.find_due_dates('resubmission')
    reviews = @assignment.find_due_dates('review') + @assignment.find_due_dates('rereview')
    @assignment.rounds_of_reviews = [@assignment.rounds_of_reviews, submissions.count, reviews.count].max

    if @assignment.directory_path.try :empty?
      @assignment.directory_path = nil
    end
  end

  def require_sign_up
  if @assignment.require_signup.nil?
      @assignment.require_signup = false
    end
  end

  def wiki_type
  if @assignment.wiki_type.nil?
      @assignment.wiki_type = WikiType.find_by_name('No')
    end
  end

  def staggered_deadline
  if @assignment.staggered_deadline.nil?
      @assignment.staggered_deadline = false
      @assignment.days_between_submissions = 0
    end
  end

  def availability_flag
  if @assignment.availability_flag.nil?
      @assignment.availability_flag = false
    end
  end

  def micro_task
  if @assignment.microtask.nil?
      @assignment.microtask = false
    end
  end

  def is_coding_assignment
  if @assignment.is_coding_assignment .nil?
      @assignment.is_coding_assignment  = false
    end
  end

  def reviews_visible_to_all
  if @assignment.reviews_visible_to_all.nil?
      @assignment.reviews_visible_to_all = false
    end
  end

  def review_assignment_strategy
  if @assignment.review_assignment_strategy.nil?
      @assignment.review_assignment_strategy = ''
    end
  end

  def require_quiz
  if @assignment.require_quiz.nil?
      @assignment.require_quiz =  false
      @assignment.num_quiz_questions =  0
    end
  end

  #NOTE: unfortunately this method is needed due to bad data in db @_@
  def set_up_defaults
    require_sign_up
    wiki_type
    staggered_deadline
    availability_flag
    micro_task
    is_coding_assignment
    reviews_visible_to_all
    review_assignment_strategy
    require_quiz
  end

  #Copies the inputted assignment into new one and returns the new assignment id
  def self.copy(assignment_id,user)
    Assignment.record_timestamps = false
    old_assign = Assignment.find(assignment_id)
    new_assign = old_assign.dup
    user.set_instructor(new_assign)
    new_assign.update_attribute('name', 'Copy of ' + new_assign.name)
    new_assign.update_attribute('created_at', Time.now)
    new_assign.update_attribute('updated_at', Time.now)
    if new_assign.directory_path.present?
      new_assign.update_attribute('directory_path', new_assign.directory_path + '_copy')
    end
    new_assign.copy_flag = true
    if new_assign.save
      Assignment.record_timestamps = true
      copy_assignment_questionnaire(old_assign,new_assign)
      DueDate.copy(old_assign.id, new_assign.id)
      new_assign.create_node
      new_assign_id=new_assign.id
    else
      new_assign_id=nil
    end
    new_assign_id
  end

  def self.copy_assignment_questionnaire (old_assign, new_assign)
    old_assign.assignment_questionnaires.each do |aq|
      AssignmentQuestionnaire.create(
          :assignment_id => new_assign.id,
          :questionnaire_id => aq.questionnaire_id,
          :user_id => session[:user].id,
          :notification_limit => aq.notification_limit,
          :questionnaire_weight => aq.questionnaire_weight
      )
    end
  end

end