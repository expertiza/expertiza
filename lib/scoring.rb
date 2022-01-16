module Scoring
  # Compute total score for this assignment by summing the scores given on all questionnaires.
  # Only scores passed in are included in this sum.
  def compute_total_score(assignment, scores)
    total = 0
    assignment.questionnaires.each {|questionnaire| total += questionnaire.get_weighted_score(assignment, scores) }
    total
  end

  # Computes and returns the scores of assignment for participants and teams
  # Returns data in the format of 
  # {
  # :particpant => {
  #   :<participant_id> => participant_scores(participant, quesitons), 
  #   :<participant_id> => participant_scores(participant, quesitons)
  #   },
  # :teams => {
  #    :0 => {:team => team, 
  #           :scores => assignment.vary_by_round ? 
  #             merge_grades_by_rounds(assignment, grades_by_rounds, total_num_of_assessments, total_score)
  #             Response.compute_scores(assessments, questions[:review])
  #          } ,
  #    :1 => {:team => team, 
  #           :scores => assignment.vary_by_round ? 
  #             merge_grades_by_rounds(assignment, grades_by_rounds, total_num_of_assessments, total_score)
  #             Response.compute_scores(assessments, questions[:review])
  #          } ,
  #   }
  # }
  def review_grades(assignment, questions)
    scores = {:participants => {}, :teams => {}}
    assignment.participants.each do |participant|
      scores[:participants][participant.id.to_s.to_sym] = participant_scores(participant, questions)
    end
    index = 0
    assignment.teams.each do |team|
      scores[:teams][index.to_s.to_sym] = {:team => team, :scores => {}}
      if assignment.vary_by_round
        grades_by_rounds, total_num_of_assessments, total_score = compute_grades_by_rounds(assignment, questions, team)
        # merge the grades from multiple rounds
        scores[:teams][index.to_s.to_sym][:scores] = merge_grades_by_rounds(assignment, grades_by_rounds, total_num_of_assessments, total_score)
      else
        assessments = ReviewResponseMap.assessments_for(team)
        scores[:teams][index.to_s.to_sym][:scores] = Response.compute_scores(assessments, questions[:review])
      end
      index += 1
    end
    scores
  end

  # Return scores that this participant has been given
  # Returns data in the format of
  # {
  #    :participant => participant
  #    :
  # }
  def participant_scores(participant, questions)
    assignment = participant.assignment
    scores = {}
    scores[:participant] = participant
    compute_assignment_score(participant, questions, scores)
    # Compute the Total Score (with question weights factored in)
    scores[:total_score] = compute_total_score(assignment, scores) 

    # merge scores[review#] (for each round) to score[review]
    merge_scores(participant, scores) if assignment.vary_by_round
    # In the event that this is a microtask, we need to scale the score accordingly and record the total possible points
    if assignment.microtask?
      topic = SignUpTopic.find_by(assignment_id: assignment.id)
      return if topic.nil?
      scores[:total_score] *= (topic.micropayment.to_f / 100.to_f) 
      scores[:max_pts_available] = topic.micropayment
    end

    scores[:total_score] = compute_total_score(assignment, scores)
    
    # update :total_score key in scores hash to user's current grade if they have one
    # update :total_score key in scores hash to 100 if the current value is greater than 100
    if participant.grade
      scores[:total_score] = participant.grade
    else
      scores[:total_score] = 100 if scores[:total_score] > 100
    end
    scores
  end

  def compute_assignment_score(participant, questions, scores)
    participant.assignment.questionnaires.each do |questionnaire|
      round = AssignmentQuestionnaire.find_by(assignment_id: participant.assignment.id, questionnaire_id: questionnaire.id).used_in_round
      # create symbol for "varying rubrics" feature -Yang
      questionnaire_symbol = if round.nil?
                               questionnaire.symbol
                             else
                               (questionnaire.symbol.to_s + round.to_s).to_sym
                             end

      scores[questionnaire_symbol] = {}

      scores[questionnaire_symbol][:assessments] = if round.nil?
                                                     questionnaire.get_assessments_for(participant)
                                                   else
                                                     questionnaire.get_assessments_round_for(participant, round)
                                                   end
      # Response.compute_scores computes the total score for a list of responses to a questionnaire                                                    
      scores[questionnaire_symbol][:scores] = Response.compute_scores(scores[questionnaire_symbol][:assessments], questions[questionnaire_symbol])
    end
  end

  # for each assignment review all scores and determine a max, min and average value
  def merge_scores(participant, scores)
    review_sym = "review".to_sym
    scores[review_sym] = {}
    scores[review_sym][:assessments] = []
    scores[review_sym][:scores] = {max: -999_999_999, min: 999_999_999, avg: 0}
    total_score = 0
    (1..participant.assignment.num_review_rounds).each do |i|
      round_sym = ("review" + i.to_s).to_sym
      # check if that assignment round is empty 
      next if scores[round_sym].nil? || scores[round_sym][:assessments].nil? || scores[round_sym][:assessments].empty?
      length_of_assessments = scores[round_sym][:assessments].length.to_f
      scores[review_sym][:assessments] += scores[round_sym][:assessments]

      # update the max value if that rounds max exists and is higher than the current max
      update_max_or_min(scores, round_sym, review_sym, :max)
      # update the min value if that rounds min exists and is lower than the current min
      update_max_or_min(scores, round_sym, review_sym, :min)
      # Compute average score for current round, and sets overall total score to be average_from_round * length of assignment (# of questions)      
      total_score += scores[round_sym][:scores][:avg] * length_of_assessments unless scores[round_sym][:scores][:avg].nil?
    end
    # if the scores max and min weren't updated set them to zero.
    if scores[review_sym][:scores][:max] == -999_999_999 && scores[review_sym][:scores][:min] == 999_999_999
      scores[review_sym][:scores][:max] = 0
      scores[review_sym][:scores][:min] = 0
    end
    # Compute the average score for a particular review (all rounds)
    scores[review_sym][:scores][:avg] = total_score / scores[review_sym][:assessments].length.to_f
  end

def update_max_or_min(scores, round_sym, review_sym, symbol)
    op = :< if symbol == :max
    op = :> if symbol == :min
      # check if there is a max/min score for this particular round
    unless scores[round_sym][:scores][symbol].nil? 
      # if scores[review_sym][:scores][symbol] (< or >) scores[round_sym][:scores][symbol]
      if scores[review_sym][:scores][symbol].send(op, scores[round_sym][:scores][symbol])
        scores[review_sym][:scores][symbol] = scores[round_sym][:scores][symbol]
      end
    end
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
  return nil if team.nil?
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

#Below private methods are extracted and added as part of refactoring project E2009 - Spring 2020
  #This method computes and returns grades by rounds, total_num_of_assessments and total_score
  # when the assignment has varying rubrics by round
  def compute_grades_by_rounds(assignment, questions, team)
    grades_by_rounds = {}
    total_score = 0
    total_num_of_assessments = 0 # calculate grades for each rounds
    (1..assignment.num_review_rounds).each do |i|
      assessments = ReviewResponseMap.get_responses_for_team_round(team, i)
      round_sym = ("review" + i.to_s).to_sym
      grades_by_rounds[round_sym] = Response.compute_scores(assessments, questions[round_sym])
      total_num_of_assessments += assessments.size
      total_score += grades_by_rounds[round_sym][:avg] * assessments.size.to_f unless grades_by_rounds[round_sym][:avg].nil?
    end
    return grades_by_rounds, total_num_of_assessments, total_score
  end

  # merge the grades from multiple rounds
  def merge_grades_by_rounds(assignment, grades_by_rounds, num_of_assessments, total_score)
    team_scores = {:max => 0, :min => 0, :avg => nil}
    if num_of_assessments.zero?
      return team_scores
    end
    team_scores[:max] = -999_999_999
    team_scores[:min] = 999_999_999
    team_scores[:avg] = total_score / num_of_assessments
    (1..assignment.num_review_rounds).each do |i|
      round_sym = ("review" + i.to_s).to_sym
      unless grades_by_rounds[round_sym][:max].nil? || team_scores[:max] >= grades_by_rounds[round_sym][:max]
        team_scores[:max] = grades_by_rounds[round_sym][:max]
      end
      unless grades_by_rounds[round_sym][:min].nil? || team_scores[:min] <= grades_by_rounds[round_sym][:min]
        team_scores[:min] = grades_by_rounds[round_sym][:min]
      end
    end
    team_scores
  end