class AssignmentForm

  attr_accessor :assignment, :assignment_questionnaires, :due_dates

  def initialize(attributes=nil)

    if attributes.nil? then

      @assignment = Assignment.new
      @assignment_questionnaires = AssignmentQuestionnaire.new
      @due_dates = DueDate.new

    else
      @assignment = Assignment.new(attributes[:assignment])
      @assignment_questionnaires = AssignmentQuestionnaire.new(attributes[:assignment_questionnaires])
      @due_dates = DueDate.new(attributes[:due_dates])
    end

  end

  #create a form object for this assignment_id
  #handle assignment quessionaire and duedate
  def self.createFormObject(assignment_id)
    assignment_form = AssignmentForm.new
    assignment_form.assignment = Assignment.find(assignment_id)
    assignment_form.assignment_questionnaires = AssignmentQuestionnaire.find_by_assignment_id(assignment_id)
    return assignment_form
  end

  # handle assignmentquessionaire and duedate
  def update_attributes(attributes)
    @assignment.update_attributes(attributes[:assignment])
  end

  #Save the assignment
  # handle assignmentquesionnaire and duedate
  def save
    @assignment.save
  end

end