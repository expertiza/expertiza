module AssignmentHelper

  def course_options(instructor)
    courses = Course.where(instructor_id: instructor.id)
    options = Array.new
    options << ['-----------', nil]
    courses.each do |course|
      options << [course.name, course.id]
    end
    options
  end

  def wiki_type_options
    wiki_type_options = Array.new
    WikiType.find_each do |wiki_type|
      if wiki_type.name == 'No'
        wiki_type_options << ['------', wiki_type.id]
      else
        wiki_type_options << [wiki_type.name, wiki_type.id]
      end
    end
    wiki_type_options
  end

  def questionnaire_options(assignment, type)
    questionnaires = Questionnaire.where( ['private = 0 or instructor_id = ?', assignment.instructor_id]).order('name')
    options = Array.new
    questionnaires.select { |x| x.type == type }.each do |questionnaire|
      options << [questionnaire.name, questionnaire.id]
    end
    options
  end

  def review_strategy_options
    review_strategy_options = Array.new
    Assignment::REVIEW_STRATEGIES.each do |strategy|
      review_strategy_options << [strategy.to_s, strategy.to_s]
    end
    review_strategy_options
  end

  def deadline_rights_options
    permissions = DeadlineRight.all
    options = Array.new
    permissions.each do |permission|
      options << [permission.name, permission.id]
    end
    options
  end

  #retrive or create a due_date
  # use in views/assignment/edit.html.erb
  def due_date(assignment, type, round = 0)
    due_dates = assignment.find_due_dates(type)

    due_dates.delete_if { |due_date| due_date.due_at.nil? }
    due_dates.sort! { |x, y| x.due_at <=> y.due_at }

    if due_dates[round].nil? or round < 0
      due_date = DueDate.new
      due_date.deadline_type = DeadlineType.find_by_name(type)
      #creating new round
      #TODO: add code to assign default permission to the newly created due_date according to the due_date type
      due_date.submission_allowed_id = DueDate.default_permission(type, 'submission_allowed')
      due_date.review_allowed_id = DueDate.default_permission(type, 'review_allowed')
      due_date.review_of_review_allowed_id = DueDate.default_permission(type, 'review_of_review_allowed')
      due_date
    else
      due_dates[round]
    end
  end


  def questionnaire(assignment, type)
    questionnaire = assignment.questionnaires.find_by_type(type)
    if questionnaire.nil?
      questionnaire = Object.const_get(type).new
    end

    questionnaire
  end

  def assignment_questionnaire(assignment, type)
    questionnaire = assignment.questionnaires.find_by_type(type)

    if questionnaire.nil?
      default_weight = Hash.new
      default_weight['ReviewQuestionnaire'] = 100
      default_weight['MetareviewQuestionnaire'] = 0
      default_weight['AuthorFeedbackQuestionnaire'] = 0
      default_weight['TeammateReviewQuestionnaire'] = 0

      default_aq = AssignmentQuestionnaire.where(user_id: assignment.instructor_id, assignment_id: nil, questionnaire_id: nil).first
      if default_aq.nil?
        default_limit = 15
      else
        default_limit = default_aq.notification_limit
      end

      aq = AssignmentQuestionnaire.new
      aq.questionnaire_weight = default_weight[type]
      aq.notification_limit = default_limit
      aq.assignment = @assignment
      aq
    else
      assignment.assignment_questionnaires.find_by_questionnaire_id(questionnaire.id)
    end
  end


end
