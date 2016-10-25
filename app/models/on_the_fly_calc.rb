module OnTheFlyCalc
  # Compute total score for this assignment by summing the scores given on all questionnaires.
  # Only scores passed in are included in this sum.
  def compute_total_score(scores)
    total = 0
    self.questionnaires.each {|questionnaire| total += questionnaire.get_weighted_score(self, scores) }
    total
  end

  # Returns hash of review_scores[reviewer_id][reviewee_id] = score
  def compute_reviews_hash
    @review_scores = {}
    @response_type = 'ReviewResponseMap'
    # @myreviewers = ResponseMap.select('DISTINCT reviewer_id').where(['reviewed_object_id = ? && type = ? ', self.id, @response_type])

    # if this assignment uses vary rubric by rounds feature, load @questions for each round
    if self.varying_rubrics_by_round? # [reviewer_id][round][reviewee_id] = score
      rounds = self.rounds_of_reviews
      for round in 1..rounds
        @response_maps = ResponseMap.where(['reviewed_object_id = ? && type = ?', self.id, @response_type])
        review_questionnaire_id = review_questionnaire_id(round)

        @questions = Question.where(['questionnaire_id = ?', review_questionnaire_id])

        @response_maps.each do |response_map|
          # Check if response is there
          @corresponding_response = Response.where(['map_id = ?', response_map.id])
          unless @corresponding_response.empty?
            @corresponding_response = @corresponding_response.reject {|response| response.round != round }
          end
          @respective_scores = {}
          @respective_scores = @review_scores[response_map.reviewer_id][round] if !@review_scores[response_map.reviewer_id].nil? && !@review_scores[response_map.reviewer_id][round].nil?

          if !@corresponding_response.empty?
            # @corresponding_response is an array, Answer.get_total_score calculate the score for the last one
            @this_review_score_raw = Answer.get_total_score(response: @corresponding_response, questions: @questions)
            if @this_review_score_raw
              @this_review_score = ((@this_review_score_raw * 100) / 100.0).round if @this_review_score_raw >= 0.0
            end
          else
            @this_review_score = -1.0
          end

          @respective_scores[response_map.reviewee_id] = @this_review_score
          @review_scores[response_map.reviewer_id] = {} if @review_scores[response_map.reviewer_id].nil?
          @review_scores[response_map.reviewer_id][round] = {} if @review_scores[response_map.reviewer_id][round].nil?
          @review_scores[response_map.reviewer_id][round] = @respective_scores
        end
      end
    else # [reviewer_id][reviewee_id] = score
      @response_maps = ResponseMap.where(['reviewed_object_id = ? && type = ?', self.id, @response_type])
      review_questionnaire_id = review_questionnaire_id()

      @questions = Question.where(['questionnaire_id = ?', review_questionnaire_id])

      @response_maps.each do |response_map|
        # Check if response is there
        @corresponding_response = Response.where(['map_id = ?', response_map.id])
        @respective_scores = {}
        @respective_scores = @review_scores[response_map.reviewer_id] unless @review_scores[response_map.reviewer_id].nil?

        if !@corresponding_response.empty?
          # @corresponding_response is an array, Answer.get_total_score calculate the score for the last one
          @this_review_score_raw = Answer.get_total_score(response: @corresponding_response, questions: @questions)
          if @this_review_score_raw
            @this_review_score = ((@this_review_score_raw * 100) / 100.0).round if @this_review_score_raw >= 0.0
          end
        else
          @this_review_score = -1.0
        end
        @respective_scores[response_map.reviewee_id] = @this_review_score
        @review_scores[response_map.reviewer_id] = @respective_scores
      end

    end
    @review_scores
  end

  # calculate the avg score and score range for each reviewee(team), only for peer-review
  def compute_avg_and_ranges_hash
    scores = {}
    contributors = self.contributors # assignment_teams
    if self.varying_rubrics_by_round?
      rounds = self.rounds_of_reviews
      for round in 1..rounds
        review_questionnaire_id = review_questionnaire_id(round)
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
      review_questionnaire_id = review_questionnaire_id()
      questions = Question.where(['questionnaire_id = ?', review_questionnaire_id])
      contributors.each do |contributor|
        assessments = ReviewResponseMap.get_assessments_for(contributor)
        scores[contributor.id] = {}
        scores[contributor.id] = Answer.compute_scores(assessments, questions)
      end
    end
    scores
  end

  def scores(questions)
    scores = {}

    scores[:participants] = {}
    self.participants.each do |participant|
      scores[:participants][participant.id.to_s.to_sym] = participant.scores(questions)
    end

    scores[:teams] = {}
    index = 0
    self.teams.each do |team|
      scores[:teams][index.to_s.to_sym] = {}
      scores[:teams][index.to_s.to_sym][:team] = team

      if self.varying_rubrics_by_round?
        grades_by_rounds = {}

        total_score = 0
        total_num_of_assessments = 0 # calculate grades for each rounds
        for i in 1..self.num_review_rounds
          assessments = ReviewResponseMap.get_assessments_round_for(team, i)
          round_sym = ("review" + i.to_s).to_sym
          grades_by_rounds[round_sym] = Answer.compute_scores(assessments, questions[round_sym])
          total_num_of_assessments += assessments.size
          unless grades_by_rounds[round_sym][:avg].nil?
            total_score += grades_by_rounds[round_sym][:avg] * assessments.size.to_f
          end
        end

        # merge the grades from multiple rounds
        scores[:teams][index.to_s.to_sym][:scores] = {}
        scores[:teams][index.to_s.to_sym][:scores][:max] = -999_999_999
        scores[:teams][index.to_s.to_sym][:scores][:min] = 999_999_999
        scores[:teams][index.to_s.to_sym][:scores][:avg] = 0
        for i in 1..self.num_review_rounds
          round_sym = ("review" + i.to_s).to_sym
          if !grades_by_rounds[round_sym][:max].nil? && scores[:teams][index.to_s.to_sym][:scores][:max] < grades_by_rounds[round_sym][:max]
            scores[:teams][index.to_s.to_sym][:scores][:max] = grades_by_rounds[round_sym][:max]
          end
          if !grades_by_rounds[round_sym][:min].nil? && scores[:teams][index.to_s.to_sym][:scores][:min] > grades_by_rounds[round_sym][:min]
            scores[:teams][index.to_s.to_sym][:scores][:min] = grades_by_rounds[round_sym][:min]
          end
        end

        if total_num_of_assessments != 0
          scores[:teams][index.to_s.to_sym][:scores][:avg] = total_score / total_num_of_assessments
        else
          scores[:teams][index.to_s.to_sym][:scores][:avg] = nil
          scores[:teams][index.to_s.to_sym][:scores][:max] = 0
          scores[:teams][index.to_s.to_sym][:scores][:min] = 0
        end

      else
        assessments = ReviewResponseMap.get_assessments_for(team)
        scores[:teams][index.to_s.to_sym][:scores] = Answer.compute_scores(assessments, questions[:review])
      end

      index += 1
    end
    scores
  end
end