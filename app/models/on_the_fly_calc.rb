# E1731 changes: this module changed to class and its methods changed to static
class OnTheFlyCalc
  # Compute total score for this assignment by summing the scores given on all questionnaires.
  # Only scores passed in are included in this sum.
  def self.compute_total_score(assignment, scores)
    total = 0
    assignment.questionnaires.each {|questionnaire| total += questionnaire.get_weighted_score(assignment, scores) }
    total
  end

  def self.compute_reviews_hash(assignment)
    @review_scores = {}
    @response_type = 'ReviewResponseMap'
    if assignment.varying_rubrics_by_round?
      @response_maps = ResponseMap.where(['reviewed_object_id = ? && type = ?', assignment.id, @response_type])
      scores_varying_rubrics(assignment)
    else
      @response_maps = ResponseMap.where(['reviewed_object_id = ? && type = ?', assignment.id, @response_type])
      scores_non_varying_rubrics(assignment)
    end
    @review_scores
  end

  # calculate the avg score and score range for each reviewee(team), only for peer-review
  def self.compute_avg_and_ranges_hash(assignment)
    scores = {}
    contributors = assignment.contributors # assignment_teams
    if assignment.varying_rubrics_by_round?
      rounds = assignment.rounds_of_reviews
      (1..rounds).each do |round|
        review_questionnaire_id = assignment.review_questionnaire_id(round)
        questions = Question.where(['questionnaire_id = ?', review_questionnaire_id])
        contributors.each do |contributor|
          assessments = ReviewResponseMap.get_assessments_for(contributor)
          assessments = assessments.reject {|assessment| assessment.round != round }
          scores[contributor.id] = {} if round == 1
          scores[contributor.id][round] = {}
          scores[contributor.id][round] = Answer.compute_scores(assessments, questions)
        end
      end
    else
      review_questionnaire_id = assignment.review_questionnaire_id()
      questions = Question.where(['questionnaire_id = ?', review_questionnaire_id])
      contributors.each do |contributor|
        assessments = ReviewResponseMap.get_assessments_for(contributor)
        scores[contributor.id] = {}
        scores[contributor.id] = Answer.compute_scores(assessments, questions)
      end
    end
    scores
  end

  # While making changes for E1731, it was noticed that below method is not used anywhere and can be removed
  def self.scores(assignment, questions)
    score_assignment(assignment)
    assignment.teams.each do |team|
      score_team = {}
      score_team[:team] = team
      if assignment.varying_rubrics_by_round?
        calculate_rounds(assignment)
        calculate_score(assignment)
        calculate_assessment
      else
        assessments = ReviewResponseMap.get_assessments_for(team)
        score_team[:scores] = Answer.compute_scores(assessments, questions[:review])
      end
      index += 1
    end
    scores
  end
end

private

def score_assignment(assignment)
  scores = {}
  score_team = scores[:teams][index.to_s.to_sym]
  scores[:participants] = {}
  participant_score(assignment)
  scores[:teams] = {}
  index = 0
end

def calculate_rounds(assignment)
  assignment.num_review_rounds.each do |i|
    total_score = 0
    total_num_of_assessments = 0 # calculate grades for each rounds
    grades_by_rounds = {}
    assessments = ReviewResponseMap.get_responses_for_team_round(team, i)
    round_sym = ("review" + i.to_s).to_sym
    grades_by_rounds[round_sym] = Answer.compute_scores(assessments, questions[round_sym])
    total_num_of_assessments += assessments.size
    total_score += grades_by_rounds[round_sym][:avg] * assessments.size.to_f unless grades_by_rounds[round_sym][:avg].nil?
  end
end

def calculate_score(assignment)
  score = {}
  score[:max] = -999_999_999
  score[:min] = 999_999_999
  score[:avg] = 0
  grades_by_rounds = {}
  assignment.num_review_rounds.each do |i|
    round_sym = ("review" + i.to_s).to_sym
    grades_by_rounds = {}
    score[:max] = grades_by_rounds[round_sym][:max] if max_condition
    score[:min] = grades_by_rounds[round_sym][:min] if min_condition
  end
end

def max_condition
  !round[:max].nil? && score[:max] < round[:max]
end

def min_condition
  !round[:min].nil? && score[:min] > round[:min]
end

def participant_score(assignment)
  assignment.participants.each do |participant|
    scores[:participants][participant.id.to_s.to_sym] = participant.scores(questions)
  end
end

def calculate_assessment
  if total_num_of_assessments.nonzero?
    score[:avg] = total_score / total_num_of_assessments
  else
    score[:avg] = nil
    score[:max] = 0
    score[:min] = 0
  end
end

def calc_review_score
  if !@corresponding_response.empty?
    @this_review_score_raw = Answer.get_total_score(response: @corresponding_response, questions: @questions)
    if @this_review_score_raw
      @this_review_score = ((@this_review_score_raw * 100) / 100.0).round if @this_review_score_raw >= 0.0
    end
  else
    @this_review_score = -1.0
  end
end

def scores_varying_rubrics(assignment)
  rounds = assignment.rounds_of_reviews
  (1..rounds).each do |round|
    review_questionnaire_id = assignment.review_questionnaire_id(round)
    @questions = Question.where(['questionnaire_id = ?', review_questionnaire_id])
    @response_maps.each do |response_map|
      reviewer = @review_scores[response_map.reviewer_id]
      @corresponding_response = Response.where(['map_id = ?', response_map.id])
      @corresponding_response = @corresponding_response.reject {|response| response.round != round } unless @corresponding_response.empty?
      @respective_scores = {}
      @respective_scores = reviewer[round] if !reviewer.nil? && !reviewer[round].nil?
      calc_review_score
      @respective_scores[response_map.reviewee_id] = @this_review_score
      reviewer = {} if reviewer.nil?
      reviewer[round] = {} if reviewer[round].nil?
      reviewer[round] = @respective_scores
    end
  end
end

def scores_non_varying_rubrics(assignment)
  review_questionnaire_id = assignment.review_questionnaire_id()
  @questions = Question.where(['questionnaire_id = ?', review_questionnaire_id])
  @response_maps.each do |response_map|
    reviewer = @review_scores[response_map.reviewer_id]
    @corresponding_response = Response.where(['map_id = ?', response_map.id])
    @respective_scores = {}
    @respective_scores = reviewer unless reviewer.nil?
    calc_review_score
    @respective_scores[response_map.reviewee_id] = @this_review_score
    @review_scores[response_map.reviewer_id] = @respective_scores
  end
end