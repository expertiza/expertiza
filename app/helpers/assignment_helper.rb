module AssignmentHelper
  def course_options(instructor)
    if session[:user].role.name == 'Teaching Assistant'
      courses = []
      ta = Ta.find(session[:user].id)
      ta.ta_mappings.each {|mapping| courses << Course.find(mapping.course_id) }
      # If a TA created some courses before, s/he can still add new assignments to these courses.
      #Only those courses should be shown in the dropdown list of courses, the assignment is part of and the instructor or TA has access to.
      courses << Course.where(instructor_id: ta.id)
      courses.flatten!
    # Administrator and Super-Administrator can see all courses
    elsif session[:user].role.name == 'Administrator' || session[:user].role.name == 'Super-Administrator'
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
    # Only instructors, but not TAs, would then be allowed to change an assignment to be part of no course
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

  # retrieve or create a due_date
  # use in views/assignment/edit.html.erb
  # Be careful it is a tricky method, for types other than "submission" and "review",
  # the parameter "round" should always be 0; for "submission" and "review" if you want
  # to get the due date for round n, the parameter "round" should be n-1.
  def due_date(assignment, type, round = 0)
    due_dates = assignment.find_due_dates(type)

    due_dates.delete_if {|due_date| due_date.due_at.nil? }
    due_dates.sort! {|x, y| x.due_at <=> y.due_at }

    if due_dates[round].nil? || round < 0
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

  # Compute total score for this assignment by summing the scores given on all questionnaires.
  # Only scores passed in are included in this sum.
  def compute_total_score(assignment, scores)
    total = 0
    assignment.questionnaires.each {|questionnaire| total += questionnaire.get_weighted_score(assignment, scores) }
    total
  end

  def compute_reviews_hash(assignment)
    review_scores = {}
    response_type = 'ReviewResponseMap'
    response_maps = ResponseMap.where(reviewed_object_id: assignment.id, type: response_type)
    if assignment.vary_by_round
      review_scores = scores_varying_rubrics(review_scores, response_maps)
    else
      review_scores = scores_non_varying_rubrics(review_scores, response_maps)
    end
    review_scores
  end

  # calculate the avg score and score range for each reviewee(team), only for peer-review
  def compute_avg_and_ranges_hash
    scores = {}
    contributors = self.contributors # assignment_teams
    if self.vary_by_round
      rounds = self.rounds_of_reviews
      (1..rounds).each do |round|
        contributors.each do |contributor|
          questions = peer_review_questions_for_team(contributor, round)
          assessments = ReviewResponseMap.assessments_for(contributor)
          assessments.select! {|assessment| assessment.round == round }
          scores[contributor.id] = {} if round == 1
          scores[contributor.id][round] = {}
          scores[contributor.id][round] = Response.compute_scores(assessments, questions)
        end
      end
    else
      contributors.each do |contributor|
        questions = peer_review_questions_for_team(contributor)
        assessments = ReviewResponseMap.assessments_for(contributor)
        scores[contributor.id] = {}
        scores[contributor.id] = Response.compute_scores(assessments, questions)
      end
    end
    scores
  end

end

private

# Get all of the questions asked during peer review for the given team's work
def peer_review_questions_for_team(team, round_number = nil)
  topic_id = SignedUpTeam.find_by(team_id: team.id).topic_id unless team.nil?
  review_questionnaire_id = review_questionnaire_id(round_number, topic_id) unless team.nil?
  Question.where(questionnaire_id: review_questionnaire_id) unless team.nil?
end

def calc_review_score(corresponding_response, questions)
  unless corresponding_response.empty?
    this_review_score_raw = Response.assessment_score(response: corresponding_response, questions: questions)
    if this_review_score_raw
      this_review_score = ((this_review_score_raw * 100) / 100.0).round if this_review_score_raw >= 0.0
    end
  else
    this_review_score = -1.0
  end
end

def scores_varying_rubrics(review_scores, response_maps)
  rounds = self.rounds_of_reviews
  (1..rounds).each do |round|
    response_maps.each do |response_map|
      questions = peer_review_questions_for_team(response_map.reviewee, round)
      reviewer = review_scores[response_map.reviewer_id]
      corresponding_response = Response.where('map_id = ?', response_map.id)
      corresponding_response = corresponding_response.select {|response| response.round == round } unless corresponding_response.empty?
      respective_scores = {}
      respective_scores = reviewer[round] unless reviewer.nil? || reviewer[round].nil?
      this_review_score = calc_review_score(corresponding_response, questions)
      respective_scores[response_map.reviewee_id] = this_review_score
      reviewer = {} if reviewer.nil?
      reviewer[round] = {} if reviewer[round].nil?
      reviewer[round] = respective_scores
    end
  end
  review_scores
end

def scores_non_varying_rubrics(review_scores, response_maps)
  response_maps.each do |response_map|
    questions = peer_review_questions_for_team(response_map.reviewee)
    reviewer = review_scores[response_map.reviewer_id]
    corresponding_response = Response.where('map_id = ?', response_map.id)
    respective_scores = {}
    respective_scores = reviewer unless reviewer.nil?
    this_review_score = calc_review_score(corresponding_response, questions)
    respective_scores[response_map.reviewee_id] = this_review_score
    review_scores[response_map.reviewer_id] = respective_scores
  end
  review_scores
end