module Scoring
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
      review_scores = scores_varying_rubrics(assignment, review_scores, response_maps)
    else
      review_scores = scores_non_varying_rubrics(assignment, review_scores, response_maps)
    end
    review_scores
  end

  # calculate the avg score and score range for each reviewee(team), only for peer-review
  def compute_avg_and_ranges_hash(assignment)
    scores = {}
    contributors = assignment.contributors # assignment_teams
    if assignment.vary_by_round
      rounds = assignment.rounds_of_reviews
      (1..rounds).each do |round|
        contributors.each do |contributor|
          questions = peer_review_questions_for_team(assignment, contributor, round)
          assessments = ReviewResponseMap.assessments_for(contributor)
          assessments.select! {|assessment| assessment.round == round }
          scores[contributor.id] = {} if round == 1
          scores[contributor.id][round] = {}
          scores[contributor.id][round] = Response.compute_scores(assessments, questions)
        end
      end
    else
      contributors.each do |contributor|
        questions = peer_review_questions_for_team(assignment, contributor)
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
def peer_review_questions_for_team(assignment, team, round_number = nil)
  
  signed_up_team = SignedUpTeam.find_by(team_id: team.id)
  topic_id = signed_up_team.topic_id unless signed_up_team.nil?
  review_questionnaire_id = assignment.review_questionnaire_id(round_number, topic_id) unless team.nil?
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

def scores_varying_rubrics(assignment, review_scores, response_maps)
  rounds = assignment.rounds_of_reviews
  (1..rounds).each do |round|
    response_maps.each do |response_map|
      questions = peer_review_questions_for_team(assignment, response_map.reviewee, round)
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

def scores_non_varying_rubrics(assignment, review_scores, response_maps)
  response_maps.each do |response_map|
    questions = peer_review_questions_for_team(assignment, response_map.reviewee)
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