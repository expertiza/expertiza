module Scoring
  # Computes the total score for a *list of assessments*
  # parameters
  #  assessments - a list of assessments of some type (e.g., author feedback, teammate review)
  #  items - the list of items that was filled out in the process of doing those assessments
  # Called in: bookmarks_controller.rb (total_average_score), scoring.rb
  def aggregate_assessment_scores(assessments, items)
    scores = {}
    if assessments.present?
      scores[:max] = -999_999_999
      scores[:min] = 999_999_999
      total_score = 0
      length_of_assessments = assessments.length.to_f
      assessments.each do |assessment|
        curr_score = assessment_score(response: [assessment], items: items)

        scores[:max] = curr_score if curr_score > scores[:max]
        scores[:min] = curr_score unless curr_score >= scores[:min] || curr_score == -1

        # Check if the review is invalid. If is not valid do not include in score calculation
        if curr_score == -1
          length_of_assessments -= 1
          curr_score = 0
        end
        total_score += curr_score
      end
      scores[:avg] = if length_of_assessments.zero?
                       0
                     else
                       total_score.to_f / length_of_assessments
                     end
    else
      scores[:max] = nil
      scores[:min] = nil
      scores[:avg] = nil
    end
    scores
  end

  # Computes the total score for an assessment
  # params
  #  assessment - specifies the assessment for which the total score is being calculated
  #  items  - specifies the list of items being evaluated in the assessment
  # Called in: bookmarks_controller.rb (specific_average_score), grades_helper.rb (score_vector), response.rb (self.score), scoring.rb
  def assessment_score(params)
    @response = params[:response].last
    return -1.0 if @response.nil?

    if @response
      items = params[:items]
      return -1.0 if items.nil?

      weighted_score = 0
      sum_of_weights = 0
      @itemnaire = Questionnaire.find(items.first.itemnaire_id)

      # Retrieve data for itemnaire (max score, sum of scores, weighted scores, etc.)
      itemnaire_data = ScoreView.itemnaire_data(items[0].itemnaire_id, @response.id)
      weighted_score = itemnaire_data.weighted_score.to_f unless itemnaire_data.weighted_score.nil?
      sum_of_weights = itemnaire_data.sum_of_weights.to_f
      answers = Answer.where(response_id: @response.id)
      answers.each do |answer|
        item = Question.find(answer.item_id)
        if answer.answer.nil? && item.is_a?(ScoredQuestion)
          sum_of_weights -= Question.find(answer.item_id).weight
        end
      end
      max_item_score = itemnaire_data.q1_max_item_score.to_f
      if sum_of_weights > 0 && max_item_score && weighted_score > 0
        return (weighted_score / (sum_of_weights * max_item_score)) * 100
      else
        return -1.0 # indicating no score
      end
    end
  end

  # Compute total score for this assignment by summing the scores given on all itemnaires.
  # Only scores passed in are included in this sum.
  # Called in: scoring.rb
  def compute_total_score(assignment, scores)
    total = 0
    assignment.itemnaires.each { |itemnaire| total += itemnaire.get_weighted_score(assignment, scores) }
    total
  end

  # Computes and returns the scores of assignment for participants and teams
  # Returns data in the format of
  # {
  # :particpant => {
  #   :<participant_id> => participant_scores(participant, items),
  #   :<participant_id> => participant_scores(participant, items)
  #   },
  # :teams => {
  #    :0 => {:team => team,
  #           :scores => assignment.vary_by_round? ?
  #             merge_grades_by_rounds(assignment, grades_by_rounds, total_num_of_assessments, total_score)
  #             : aggregate_assessment_scores(assessments, items[:review])
  #          } ,
  #    :1 => {:team => team,
  #           :scores => assignment.vary_by_round? ?
  #             merge_grades_by_rounds(assignment, grades_by_rounds, total_num_of_assessments, total_score)
  #             : aggregate_assessment_scores(assessments, items[:review])
  #          } ,
  #   }
  # }
  # Called in: grades_controller.rb (view), assignment.rb (self.export)
  def review_grades(assignment, items)
    scores = { participants: {}, teams: {} }
    assignment.participants.each do |participant|
      scores[:participants][participant.id.to_s.to_sym] = participant_scores(participant, items)
    end
    assignment.teams.each_with_index do |team, index|
      scores[:teams][index.to_s.to_sym] = { team: team, scores: {} }
      if assignment.varying_rubrics_by_round?
        grades_by_rounds, total_num_of_assessments, total_score = compute_grades_by_rounds(assignment, items, team)
        # merge the grades from multiple rounds
        scores[:teams][index.to_s.to_sym][:scores] = merge_grades_by_rounds(assignment, grades_by_rounds, total_num_of_assessments, total_score)
      else
        assessments = ReviewResponseMap.assessments_for(team)
        scores[:teams][index.to_s.to_sym][:scores] = aggregate_assessment_scores(assessments, items[:review])
      end
    end
    scores
  end

  # Return scores that this participant has been given
  # Returns data in the format of
  # {
  #    :total_score => participant.grade ? particpant.grade : compute_total_score(assignment, scores)
  #    :max_pts_available => topic.micropayment if assignment.topics?
  #    :participant => participant,
  #    :itemnaire_symbol1 => {
  #       :assessments => {review1, review2},
  #       :scores => aggregate_assessment_scores(scores[itemnaire_symbol][:assessments], items[itemnaire_symbol])
  #     },
  #    :itemnaire_symbol2 => {
  #      :assessments => {review3, review4},
  #      :scores => aggregate_assessment_scores(scores[itemnaire_symbol][:assessments], items[itemnaire_symbol])
  #     },
  #     :review => {
  #       :assessments => [review1, review2, review3, review4],
  #       :scores => {:max => max_score, :min => min_score, :avg => average_score}
  #   }
  # }
  # Called in: assessment360_controller.rb (find_peer_review_score), grades_controller.rb (view_my_scores, view_team, edit), scoring.rb
  def participant_scores(participant, items)
    assignment = participant.assignment
    scores = {}
    scores[:participant] = participant
    compute_assignment_score(participant, items, scores)
    # Compute the Total Score (with item weights factored in)
    scores[:total_score] = compute_total_score(assignment, scores)

    # merge scores[review#] (for each round) to score[review]
    merge_scores(participant, scores) if assignment.varying_rubrics_by_round?
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

  # this function modifies the scores object passed to it from participant_grades
  # this function should not be called in other contexts, since it is highly dependent on a specific scores structure, described above
  # retrieves the symbol of eeach itemnaire associated with a participant on a given assignment
  # returns all the associated reviews with a participant, indexed under :assessments
  # returns the score assigned for the TOTAL body of responses associated with the user
  # Called in: scoring.rb
  def compute_assignment_score(participant, items, scores)
    participant.assignment.itemnaires.each do |itemnaire|
      round = AssignmentQuestionnaire.find_by(assignment_id: participant.assignment.id, itemnaire_id: itemnaire.id).used_in_round
      # create symbol for "varying rubrics" feature -Yang
      itemnaire_symbol = if round.nil?
                               itemnaire.symbol
                             else
                               (itemnaire.symbol.to_s + round.to_s).to_sym
                             end
      scores[itemnaire_symbol] = {}

      scores[itemnaire_symbol][:assessments] = if round.nil?
                                                     itemnaire.get_assessments_for(participant)
                                                   else
                                                     itemnaire.get_assessments_round_for(participant, round)
                                                   end
      # aggregate_assessment_scores computes the total score for a list of responses to a itemnaire
      scores[itemnaire_symbol][:scores] = aggregate_assessment_scores(scores[itemnaire_symbol][:assessments], items[itemnaire_symbol])
    end
  end

  # for each assignment review all scores and determine a max, min and average value
  # this will be called when the assignment has various rounds, so we need to aggregate the scores across rounds
  # achieves this by returning all the reviews, no longer delineated by round, and by returning the max, min and average
  # Called in: scoring.rb
  def merge_scores(participant, scores)
    review_sym = 'review'.to_sym
    scores[review_sym] = {}
    scores[review_sym][:assessments] = []
    scores[review_sym][:scores] = { max: -999_999_999, min: 999_999_999, avg: 0 }
    total_score = 0
    (1..participant.assignment.num_review_rounds).each do |i|
      round_sym = ('review' + i.to_s).to_sym
      # check if that assignment round is empty
      next if scores[round_sym].nil? || scores[round_sym][:assessments].nil? || scores[round_sym][:assessments].empty?

      length_of_assessments = scores[round_sym][:assessments].length.to_f
      scores[review_sym][:assessments] += scores[round_sym][:assessments]

      # update the max value if that rounds max exists and is higher than the current max
      update_max_or_min(scores, round_sym, review_sym, :max)
      # update the min value if that rounds min exists and is lower than the current min
      update_max_or_min(scores, round_sym, review_sym, :min)
      # Compute average score for current round, and sets overall total score to be average_from_round * length of assignment (# of items)
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

  # Called in: scoring.rb
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

  # Called in: report_formatter_helper.rb (review_response_map)
  def compute_reviews_hash(assignment)
    review_scores = {}
    response_type = 'ReviewResponseMap'
    response_maps = ResponseMap.where(reviewed_object_id: assignment.id, type: response_type)
    if assignment.varying_rubrics_by_round?
      review_scores = scores_varying_rubrics(assignment, review_scores, response_maps)
    else
      review_scores = scores_non_varying_rubrics(assignment, review_scores, response_maps)
    end
    review_scores
  end

  # calculate the avg score and score range for each reviewee(team), only for peer-review
  # Called in: report_formatter_helper.rb (review_response_map)
  def compute_avg_and_ranges_hash(assignment)
    scores = {}
    contributors = assignment.contributors # assignment_teams
    if assignment.varying_rubrics_by_round?
      rounds = assignment.rounds_of_reviews
      (1..rounds).each do |round|
        contributors.each do |contributor|
          items = peer_review_items_for_team(assignment, contributor, round)
          assessments = ReviewResponseMap.assessments_for(contributor)
          assessments.select! { |assessment| assessment.round == round }
          scores[contributor.id] = {} if round == 1
          scores[contributor.id][round] = {}
          scores[contributor.id][round] = aggregate_assessment_scores(assessments, items)
        end
      end
    else
      contributors.each do |contributor|
        items = peer_review_items_for_team(assignment, contributor)
        assessments = ReviewResponseMap.assessments_for(contributor)
        scores[contributor.id] = {}
        scores[contributor.id] = aggregate_assessment_scores(assessments, items)
      end
    end
    scores
  end
end

private

# Get all of the items asked during peer review for the given team's work
def peer_review_items_for_team(assignment, team, round_number = nil)
  return nil if team.nil?

  signed_up_team = SignedUpTeam.find_by(team_id: team.id)
  topic_id = signed_up_team.topic_id unless signed_up_team.nil?
  review_itemnaire_id = assignment.review_itemnaire_id(round_number, topic_id) unless team.nil?
  Question.where(itemnaire_id: review_itemnaire_id).to_a unless team.nil?
end

def calc_review_score(corresponding_response, items)
  if corresponding_response.empty?
    return -1.0
  else
    this_review_score_raw = assessment_score(response: corresponding_response, items: items)
    if this_review_score_raw
      return ((this_review_score_raw * 100) / 100.0).round if this_review_score_raw >= 0.0
    end
  end
end

def scores_varying_rubrics(assignment, review_scores, response_maps)
  rounds = assignment.rounds_of_reviews
  (1..rounds).each do |round|
    response_maps.each do |response_map|
      items = peer_review_items_for_team(assignment, response_map.reviewee, round)
      reviewer = review_scores[response_map.reviewer_id]
      corresponding_response = Response.where('map_id = ?', response_map.id)
      corresponding_response = corresponding_response.select { |response| response.round == round } unless corresponding_response.empty?
      respective_scores = {}
      respective_scores = reviewer[round] unless reviewer.nil? || reviewer[round].nil?
      this_review_score = calc_review_score(corresponding_response, items)
      review_scores[response_map.reviewer_id] = {} unless review_scores[response_map.reviewer_id]
      respective_scores[response_map.reviewee_id] = this_review_score
      review_scores[response_map.reviewer_id][round] = respective_scores
      reviewer = {} if reviewer.nil?
      reviewer[round] = {} if reviewer[round].nil?
      reviewer[round] = respective_scores
    end
  end
  review_scores
end

def scores_non_varying_rubrics(assignment, review_scores, response_maps)
  response_maps.each do |response_map|
    items = peer_review_items_for_team(assignment, response_map.reviewee)
    reviewer = review_scores[response_map.reviewer_id]
    corresponding_response = Response.where('map_id = ?', response_map.id)
    respective_scores = {}
    respective_scores = reviewer unless reviewer.nil?
    this_review_score = calc_review_score(corresponding_response, items)
    respective_scores[response_map.reviewee_id] = this_review_score
    review_scores[response_map.reviewer_id] = respective_scores
  end
  review_scores
end

# Below private methods are extracted and added as part of refactoring project E2009 - Spring 2020
# This method computes and returns grades by rounds, total_num_of_assessments and total_score
# when the assignment has varying rubrics by round
def compute_grades_by_rounds(assignment, items, team)
  grades_by_rounds = {}
  total_score = 0
  total_num_of_assessments = 0 # calculate grades for each rounds
  (1..assignment.num_review_rounds).each do |i|
    assessments = ReviewResponseMap.get_responses_for_team_round(team, i)
    round_sym = ('review' + i.to_s).to_sym
    grades_by_rounds[round_sym] = aggregate_assessment_scores(assessments, items[round_sym])
    total_num_of_assessments += assessments.size
    total_score += grades_by_rounds[round_sym][:avg] * assessments.size.to_f unless grades_by_rounds[round_sym][:avg].nil?
  end
  [grades_by_rounds, total_num_of_assessments, total_score]
end

# merge the grades from multiple rounds
def merge_grades_by_rounds(assignment, grades_by_rounds, num_of_assessments, total_score)
  team_scores = { max: 0, min: 0, avg: nil }
  return team_scores if num_of_assessments.zero?

  team_scores[:max] = -999_999_999
  team_scores[:min] = 999_999_999
  team_scores[:avg] = total_score / num_of_assessments
  (1..assignment.num_review_rounds).each do |i|
    round_sym = ('review' + i.to_s).to_sym
    unless grades_by_rounds[round_sym][:max].nil? || team_scores[:max] >= grades_by_rounds[round_sym][:max]
      team_scores[:max] = grades_by_rounds[round_sym][:max]
    end
    unless grades_by_rounds[round_sym][:min].nil? || team_scores[:min] <= grades_by_rounds[round_sym][:min]
      team_scores[:min] = grades_by_rounds[round_sym][:min]
    end
  end
  team_scores
end
