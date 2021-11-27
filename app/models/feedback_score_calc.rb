module FeedbackScoreCalc
  # Build a hash for the author feedback scores
  #
  # author_feedback_scores[reviewer.id][round][reviewee.id] returns the average author feedback
  # score for AssignmentParticipant reviewer's review of the AssignmentTeam reviewee.
  def compute_author_feedback_scores
    @author_feedback_scores = {}
    @response_maps = ResponseMap.where('reviewed_object_id = ? && type = ?', self.id, 'ReviewResponseMap')
    rounds = self.num_review_rounds
    (1..rounds).each do |round|
      # Loop over every review that this user completed
      @response_maps.each do |response_map|
        response = Response.where('map_id = ?', response_map.id)
        response = response.select {|response| response.round == round }
        @round = round
        @response_map = response_map
        # Calculate the average score given by the team to the review and add it to author_feedback_scores
        calc_avg_feedback_score(response) unless response.empty?
      end
    end
    @author_feedback_scores
  end

  # Fill the author_feedback_scores hash for this response (review).
  def calc_avg_feedback_score(response)
    # Retrieve the author feedback response maps for the teammates reviewing the review of their work.
    author_feedback_response_maps = ResponseMap.where('reviewed_object_id = ? && type = ?', response.first.id, 'FeedbackResponseMap')
    author_feedback_response_maps.each do |author_feedback_response_map|
      @corresponding_response = Response.where('map_id = ?', author_feedback_response_map.id)
      next if @corresponding_response.empty?
      calc_feedback_scores_sum
    end
    # Divide the sum of the author feedback scores for this review by their number to get the
    # average.

    if !@author_feedback_scores[@response_map.reviewer_id].nil? &&
      !@author_feedback_scores[@response_map.reviewer_id][@round].nil? &&
      !@author_feedback_scores[@response_map.reviewer_id][@round][@response_map.reviewee_id].nil? &&
      !author_feedback_response_maps.empty?
      @author_feedback_scores[@response_map.reviewer_id][@round][@response_map.reviewee_id] /= author_feedback_response_maps.count
    end
  end

  # Add the score of the feedback attached to this feedback response (review) to the sum of feedback scores
  # for the response (review) reviewed by one of the authors.
  def calc_feedback_scores_sum
    @respective_scores = {}
    if !@author_feedback_scores[@response_map.reviewer_id].nil? && !@author_feedback_scores[@response_map.reviewer_id][@round].nil?
      @respective_scores = @author_feedback_scores[@response_map.reviewer_id][@round]
    end
    # Get the questionnaire id from the answer corresponding to the response
    corresponding_answers = Answer.where('response_id = ?', @corresponding_response.first.id)
    corresponding_question = Question.find(corresponding_answers.first.question_id)
    @questions = Question.where('questionnaire_id = ?', corresponding_question.questionnaire_id)
    # Calculate the score of the author feedback review.
    calc_feedback_review_score
    # Compute the sum of the author feedback scores for this review.
    @respective_scores[@response_map.reviewee_id] = 0 if @respective_scores[@response_map.reviewee_id].nil?
    @respective_scores[@response_map.reviewee_id] += @this_review_score
    # The reviewer is the metareviewee whose review the authors or teammates are reviewing.
    @author_feedback_scores[@response_map.reviewer_id] = {} if @author_feedback_scores[@response_map.reviewer_id].nil?
    @author_feedback_scores[@response_map.reviewer_id][@round] = {} if @author_feedback_scores[@response_map.reviewer_id][@round].nil?
    @author_feedback_scores[@response_map.reviewer_id][@round] = @respective_scores
  end

  def calc_feedback_review_score
    if !@corresponding_response.empty?
      @this_review_score_raw = Response.assessment_score(response: @corresponding_response, questions: @questions)
      if @this_review_score_raw
        @this_review_score = ((@this_review_score_raw * 100) / 100.0).round if @this_review_score_raw >= 0.0
      end
    else
      @this_review_score = -1.0
    end
  end

end
