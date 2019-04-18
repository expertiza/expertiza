module AssignmentHelper
  def course_options(instructor)
    if session[:user].role.name == 'Teaching Assistant'
      courses = []
      ta = Ta.find(session[:user].id)
      ta.ta_mappings.each {|mapping| courses << Course.find(mapping.course_id) }
      # If a TA created some courses before, s/he can still add new assignments to these courses.
      courses << Course.where(instructor_id: instructor.id)
      courses.flatten!
    # Administrator and Super-Administrator can see all courses
    elsif session[:user].role.name == 'Administrator' or session[:user].role.name == 'Super-Administrator'
      courses = Course.all
    elsif session[:user].role.name == 'Instructor'
      courses = Course.where(instructor_id: instructor.id)
      # instructor can see courses his/her TAs created
      ta_ids = []
      ta_ids << Instructor.get_my_tas(session[:user].id)
      ta_ids.flatten!
      ta_ids.each do |ta_id|
        ta = Ta.find(ta_id)
        ta.ta_mappings.each {|mapping| courses << Course.find(mapping.course_id) }
      end
    end
    options = []
    options << ['-----------', nil]
    courses.each do |course|
      options << [course.name, course.id]
    end
    options.uniq.sort
  end

  # round=0 added by E1450
  def questionnaire_options(assignment, type, _round = 0)
    questionnaires = Questionnaire.where(['private = 0 or instructor_id = ?', assignment.instructor_id]).order('name')
    options = []
    questionnaires.select {|x| x.type == type }.each do |questionnaire|
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

  # retrive or create a due_date
  # use in views/assignment/edit.html.erb
  # Be careful it is a tricky method, for types other than "submission" and "review",
  # the parameter "round" should always be 0; for "submission" and "review" if you want
  # to get the due date for round n, the parameter "round" should be n-1.
  def due_date(assignment, type, round = 0)
    due_dates = assignment.find_due_dates(type)

    due_dates.delete_if {|due_date| due_date.due_at.nil? }
    due_dates.sort! {|x, y| x.due_at <=> y.due_at }

    if due_dates[round].nil? or round < 0
      due_date = AssignmentDueDate.new
      due_date.deadline_type_id = DeadlineType.find_by(name: type).id
      # creating new round
      # TODO: add code to assign default permission to the newly created due_date according to the due_date type
      due_date.submission_allowed_id = AssignmentDueDate.default_permission(type, 'submission_allowed')
      due_date.review_allowed_id = AssignmentDueDate.default_permission(type, 'can_review')
      due_date.review_of_review_allowed_id = AssignmentDueDate.default_permission(type, 'review_of_review_allowed')
      due_date
    else
      due_dates[round]
    end
  end

  # Find a questionnaire for the given assignment
  # Find by type if round number & topic id not given
  # Find by round number alone if round number alone is given
  # Find by topic id alone if topic id alone is given
  # Find by round number and topic id if both are given
  # Create new questionnaire of given type if no luck with any of these attempts
  def questionnaire(assignment, questionnaire_type, round_number = nil, topic_id = nil)
    if round_number.nil? && topic_id.nil?
      # Find by type
      questionnaire = assignment.questionnaires.find_by(type: questionnaire_type)
    elsif topic_id.nil?
      # Find by round
      aq = assignment.assignment_questionnaires.find_by(used_in_round: round_number)
    elsif round_number.nil?
      # Find by topic
      aq = assignment.assignment_questionnaires.find_by(topic_id: topic_id)
    else
      # Find by round and topic
      aq = assignment.assignment_questionnaires.where(used_in_round: round_number, topic_id: topic_id).first
    end
    # get the questionnaire from the assignment_questionnaire relationship
    questionnaire = aq.nil? ? questionnaire : assignment.questionnaires.find_by(id: aq.questionnaire_id)
    # couldn't find a questionnaire? create a questionnaire of the given type
    questionnaire.nil? ? Object.const_get(questionnaire_type).new : questionnaire
  end

  # Find an assignment_questionnaire relationship for the given assignment
  # Find by type if round number & topic id not given
  #   Create a new assignment_questionnaire if no luck with given type
  # Otherwise
  #   Find by round number alone if round number alone is given
  #   Find by topic id alone if topic id alone is given
  #   Find by round number and topic id if both are given
  #   Find by type if no luck with given round / topic
  def assignment_questionnaire(assignment, questionnaire_type, round_number = nil, topic_id = nil)
    q_by_type = assignment.questionnaires.find_by(type: questionnaire_type)
    if q_by_type.nil?
      # Create a new assignment_questionnaire if no luck with given type
      default_weight = {}
      default_weight['ReviewQuestionnaire'] = 100
      default_weight['MetareviewQuestionnaire'] = 0
      default_weight['AuthorFeedbackQuestionnaire'] = 0
      default_weight['TeammateReviewQuestionnaire'] = 0
      default_weight['BookmarkRatingQuestionnaire'] = 0
      default_aq = AssignmentQuestionnaire.where(user_id: assignment.instructor_id, assignment_id: nil, questionnaire_id: nil).first
      default_limit = if default_aq.nil?
                        15
                      else
                        default_aq.notification_limit
                      end

      aq = AssignmentQuestionnaire.new
      aq.questionnaire_weight = default_weight[questionnaire_type]
      aq.notification_limit = default_limit
      aq.assignment = @assignment
      aq
    else
      # No need to create a new assignment_questionnaire, should already have one
      aq_by_type = assignment.assignment_questionnaires.find_by(questionnaire_id: q_by_type.id)
      if round_number.nil? && topic_id.nil?
        # Find by type
        aq = aq_by_type
      elsif topic_id.nil?
        # Find by round
        aq = assignment.assignment_questionnaires.find_by(used_in_round: round_number)
      elsif round_number.nil?
        # Find by topic
        aq = assignment.assignment_questionnaires.find_by(topic_id: topic_id)
      else
        # Find by round and topic
        aq = assignment.assignment_questionnaires.where(used_in_round: round_number, topic_id: topic_id).first
      end
      aq.nil? ? aq_by_type : aq
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
      participants << Participant.where(["parent_id = ? AND user_id = ?", @assignment.id, user.id]).first
    end
    [topic_identifier ||= "", topic_name ||= "", users_for_curr_team, participants]
  end

  def get_team_name_color_in_list_submission(team)
    if team.try(:grade_for_submission) && team.try(:comment_for_submission)
      '#cd6133' # brown. submission grade has been assigned.
    else
      '#0984e3' # submission grade is not assigned yet.
    end
  end
end
