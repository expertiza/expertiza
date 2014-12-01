class AssignmentForm

  attr_accessor :assignment, :assignment_questionnaires, :due_dates


  def initialize(attributes={})
    @assignment = Assignment.new(attributes[:assignment])

    #code for new assignment creation
    if attributes[:assignment].nil?
      @assignment.course = Course.find(attributes[:parent_id]) if attributes[:parent_id]
      @assignment.instructor = @assignment.course.instructor if @assignment.course
      @assignment.wiki_type_id = 1 #default no wiki type
      @assignment.max_team_size = 1
    end

    @assignment_questionnaires=[]
    unless attributes[:assignment_questionnaires].nil?
      attributes[:assignment_questionnaires].each do |assignment_questionnaire|
        @assignment_questionnaires << AssignmentQuestionnaire.new(assignment_questionnaire)
      end
    end

    @due_dates=[]
    unless attributes[:due_dates].nil?
      attributes[:due_dates].each do |due_date|
        @due_dates << DueDate.new(due_date)
      end
    end
  end

  #create a form object for this assignment_id
  #handle assignment quessionaire and duedate
  def self.create_form_object(assignment_id)
    assignment_form = AssignmentForm.new
    assignment_form.assignment = Assignment.find(assignment_id)
    assignment_form.assignment_questionnaires = AssignmentQuestionnaire.where(assignment_id: assignment_id)
    assignment_form.due_dates = DueDate.where(assignment_id: assignment_id)

    assignment_form.set_up_assignment_review

    return assignment_form
  end


  def update_attributes(attributes)

    has_errors = false;
    has_late_policy = false;


    if attributes[:assignment][:late_policy_id].to_i > 0
      has_late_policy=true
    else
      attributes[:assignment][:late_policy_id] = nil
    end

    #Code to update values of assignments
    unless @assignment.update_attributes(attributes[:assignment])
      @errors =@errors + @assignment.errors
      has_errors = true;
    end

   #code to save assigment questionaires
    i =0 ;
    while i < attributes[:assignment_questionnaire].length
      if attributes[:assignment_questionnaire][i][:id].nil? or attributes[:assignment_questionnaire][i][:id].blank?
        assignment_questionnaire = AssignmentQuestionnaire.new(attributes[:assignment_questionnaire][i])
        unless assignment_questionnaire.save
          @errors =@errors + @assignment.errors
          has_errors = true;
        end
      else
        assignment_questionnaire = AssignmentQuestionnaire.find(attributes[:assignment_questionnaire][i][:id])
        unless assignment_questionnaire.update_attributes(attributes[:assignment_questionnaire][i]);
          @errors =@errors + @assignment.errors
          has_errors = true;
        end
      end
      i=i+1;
    end

  #code to save due dates
  i =0 ;
  while i < attributes[:due_date].length
    if attributes[:due_date][i][:id].nil? or attributes[:due_date][i][:id].blank?
      if attributes[:due_date][i][:due_at].blank? then
        i=i+1;
        next
      end
      due_date = DueDate.new(attributes[:due_date][i])
      unless due_date.save
        @errors =@errors + @assignment.errors
        has_errors = true;
      end
    else
      due_date = DueDate.find(attributes[:due_date][i][:id])
      unless due_date.update_attributes(attributes[:due_date][i]);
        @errors =@errors + @assignment.errors
        has_errors = true;
      end
    end
    i=i+1;
  end

   #delete the old queued items and recreate new ones.
   if attributes[:due_date] and !has_errors and has_late_policy

     # delete the previous jobs from the delayed_jobs table
     djobs = Delayed::Job.where(['handler LIKE "%assignment_id: ?%"', @assignment.id])
     for dj in djobs
       delete_from_delayed_queue(dj.id)
     end

     add_to_delayed_queue
   end

  return !has_errors;

  end

  #Adds items to delayed_jobs queue for this assignment
  def add_to_delayed_queue
    duedates = DueDate::where(assignment_id: @assignment.id)
    for i in (0 .. duedates.length-1)
      deadline_type = DeadlineType.find(duedates[i].deadline_type_id).name
      due_at = duedates[i].due_at.to_s(:db)
      Time.parse(due_at)
      due_at= Time.parse(due_at)
      mi=find_min_from_now(due_at)
      diff = mi-(duedates[i].threshold)*60
      if diff>0
        dj=Delayed::Job.enqueue(DelayedMailer.new(@assignment.id, deadline_type, duedates[i].due_at.to_s(:db)),
                                1, diff.minutes.from_now)
        duedates[i].update_attribute(:delayed_job_id, dj.id)
      end
    end
  end

  # Deletes the job with id equal to "delayed_job_id" from the delayed_jobs queue
  def delete_from_delayed_queue(delayed_job_id)
    dj=Delayed::Job.find(delayed_job_id)
    if (dj != nil && dj.id != nil)
      dj.delete
    end
  end

  # This functions finds the epoch time in seconds of the due_at parameter and finds the difference of it
  # from the current time and returns this difference in minutes
  def find_min_from_now(due_at)

    curr_time=DateTime.now.to_s(:db)
    curr_time=Time.parse(curr_time)
    time_in_min=((due_at - curr_time).to_i/60)
    return time_in_min
  end

#Save the assignment
  # handle assignmentquesionnaire and duedate
  def save
    @assignment.save
  end

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


end