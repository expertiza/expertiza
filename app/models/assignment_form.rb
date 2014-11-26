class AssignmentForm

  attr_accessor :assignment, :assignment_questionnaires, :due_dates


  def initialize(attributes=nil)

    if attributes.nil? then

      @assignment = Assignment.new
      @assignment_questionnaires = []
      @due_dates = []

    else

      @assignment = Assignment.new(attributes[:assignment])

      @assignment_questionnaires=[]
      attributes[:assignment_questionnaires].each do |assignment_questionnaire|
          @assignment_questionnaires << AssignmentQuestionnaire.new(assignment_questionnaire)
      end

      @due_dates = DueDate.new(attributes[:due_dates])
    end

  end

  #create a form object for this assignment_id
  #handle assignment quessionaire and duedate
  def self.createFormObject(assignment_id)
    assignment_form = AssignmentForm.new
    assignment_form.assignment = Assignment.find(assignment_id)
    assignment_form.assignment_questionnaires = AssignmentQuestionnaire.where(assignment_id: assignment_id)

    assignment_form.set_up_assignment_review

    return assignment_form
  end

  # handle assignmentquessionaire and duedate
  def update_attributes(attributes)

   has_errors = false;
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
          has_errors = true;0
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

    return !has_errors;

  end

  #Save the assignment
  # handle assignmentquesionnaire and duedate
  def save
    @assignment.save
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

  #NOTE: unfortunately this method is needed due to bad data in db @_@
  def set_up_defaults
    if @assignment.require_signup.nil?
      @assignment.require_signup = false
    end
    if @assignment.wiki_type.nil?
      @assignment.wiki_type = WikiType.find_by_name('No')
    end
    if @assignment.staggered_deadline.nil?
      @assignment.staggered_deadline = false
      @assignment.days_between_submissions = 0
    end
    if @assignment.availability_flag.nil?
      @assignment.availability_flag = false
    end
    if @assignment.microtask.nil?
      @assignment.microtask = false
    end
    if @assignment.is_coding_assignment .nil?
      @assignment.is_coding_assignment  = false
    end
    if @assignment.reviews_visible_to_all.nil?
      @assignment.reviews_visible_to_all = false
    end
    if @assignment.review_assignment_strategy.nil?
      @assignment.review_assignment_strategy = ''
    end
    if @assignment.require_quiz.nil?
      @assignment.require_quiz =  false
      @assignment.num_quiz_questions =  0
    end
  end


end