class OnTheFlyCal< ScoreCal

  def self.calc_score(params)

    @response = params[:response].last
    if @response
      @questions = params[:questions]

      weighted_score = 0
      sum_of_weights = 0
      max_question_score = 0

      @questionnaire = Questionnaire.find(@questions[0].questionnaire_id)

      questionnaireData = ScoreView.find_by_sql ["SELECT q1_max_question_score ,SUM(question_weight) as sum_of_weights,SUM(question_weight * s_score) as weighted_score FROM score_views WHERE type in('Criterion', 'Scale') AND q1_id = ? AND s_response_id = ?", @questions[0].questionnaire_id, @response.id]
      weighted_score = if !questionnaireData[0].weighted_score.nil?
                         questionnaireData[0].weighted_score.to_f
                       else
                         nil
                       end
      sum_of_weights = questionnaireData[0].sum_of_weights.to_f

      all_answers_for_curr_response = Answer.where(response_id: @response.id)
      all_answers_for_curr_response.each do |answer|
        question = Question.find(answer.question_id)

        if answer.answer.nil? && question.is_a?(ScoredQuestion)
          question_weight = Question.find(answer.question_id).weight
          sum_of_weights -= question_weight
        end
      end
      max_question_score = questionnaireData[0].q1_max_question_score.to_f

      if sum_of_weights > 0 && max_question_score && !weighted_score.nil?
        return (weighted_score / (sum_of_weights * max_question_score)) * 100
      else
        return -1.0
      end
    end
  end


end