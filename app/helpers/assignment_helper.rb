module AssignmentHelper
  def course_options(instructor = nil)
    courses = []
    if session[:user].role.name == 'Teaching Assistant'
      ta = Ta.find(session[:user].id)
      ta.ta_mappings.each { |mapping| courses << Course.find(mapping.course_id) }
      # If a TA created some courses before, s/he can still add new assignments to these courses.
      # Only those courses should be shown in the dropdown list of courses, the assignment is part of and the instructor or TA has access to.
      courses << Course.where(instructor_id: ta.id)
    # Administrator and Super-Administrator can see all courses
    elsif session[:user].role.name == 'Administrator' || session[:user].role.name == 'Super-Administrator'
      courses << Course.all
    elsif session[:user].role.name == 'Instructor'
      courses << Course.where(instructor_id: session[:user].id)
      # instructor can see courses his/her TAs created
      ta_ids = []
      instructor = Instructor.find(session[:user].id)
      ta_ids << instructor.my_tas
      ta_ids.flatten!
      ta_ids.each do |ta_id|
        ta = Ta.find(ta_id)
        ta.ta_mappings.each { |mapping| courses << Course.find(mapping.course_id) }
      end
    end
    courses.flatten!
    options = []
    if session[:user].role.name == 'Administrator' || session[:user].role.name == 'Super-Administrator' || session[:user].role.name == 'Instructor'
      options << ['-----------', nil]
    end
    courses.each do |course|
      options << [course.name, course.id]
    end
    options.uniq.sort
  end

  # round=0 added by E1450
  def questionnaire_options(type)
    questionnaires = Questionnaire.where(['private = 0 or instructor_id = ?', session[:user].id]).order('name')
    options = []
    questionnaires.select { |x| x.type == type }.each do |questionnaire|
      options << [questionnaire.name, questionnaire.id]
    end
    options
  end

  def review_strategy_options
    review_strategy_options = []
    Assignment::REVIEW_STRATEGIES.each do |strategy|
      review_strategy_options << [strategy.to_s, strategy.to_s]
    end
    review_strategy_options
  end

  # retrieve or create a due_date
  # use in views/assignment/edit.html.erb
  # Be careful it is a tricky method, for types other than "submission" and "review",
  # the parameter "round" should always be 0; for "submission" and "review" if you want
  # to get the due date for round n, the parameter "round" should be n-1.
  def due_date(assignment, type, round = 0)
    due_dates = assignment.find_due_dates(type)

    due_dates.delete_if { |due_date| due_date.due_at.nil? }
    due_dates.sort! { |x, y| x.due_at <=> y.due_at }

    if due_dates[round].nil? || round < 0
      due_date = AssignmentDueDate.new
      due_date.deadline_type_id = DeadlineType.find_by(name: type).id
      # creating new round
      due_date.submission_allowed_id = AssignmentDueDate.default_permission(type, 'submission_allowed')
      due_date.review_allowed_id = AssignmentDueDate.default_permission(type, 'can_review')
      due_date.review_of_review_allowed_id = AssignmentDueDate.default_permission(type, 'review_of_review_allowed')
      due_date
    else
      due_dates[round]
    end
  end

  def get_data_for_list_submissions(team)
    teams_users = TeamsUser.where(team_id: team.id)
    topic = SignedUpTeam.where(team_id: team.id).first.try :topic
    topic_identifier = topic.try :topic_identifier
    topic_name = topic.try :topic_name
    users_for_curr_team = []
    participants = []
    teams_users.each do |teams_user|
      user = User.find(teams_user.user_id)
      users_for_curr_team << user
      participants << Participant.where(['parent_id = ? AND user_id = ?', @assignment.id, user.id]).first
    end
    topic_identifier ||= ''
    topic_name ||= ''
    [topic_identifier, topic_name, users_for_curr_team, participants]
  end

  def get_team_name_color_in_list_submission(team)
    if team.try(:grade_for_submission) && team.try(:comment_for_submission)
      '#cd6133' # brown. submission grade has been assigned.
    else
      '#0984e3' # submission grade is not assigned yet.
    end
  end
end
