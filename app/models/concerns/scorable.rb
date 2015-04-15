# This module is included in the Assignment model.
# It handles the score calculation logic for the Assignment.
module Scorable
  extend ActiveSupport::Concern

  # Compute total score for this assignment by summing the scores given on all questionnaires.
  # Only scores passed in are included in this sum.
  def compute_total_score(scores)
    questionnaires.inject(0) { |total, questionnaire| total + questionnaire.get_weighted_score(self, scores) }
  end

  # Returns hash review_scores[reviewer_id][reviewee_id] = score
  def compute_reviews_hash
    review_questionnaire_id = get_review_questionnaire_id
    questions = Question.where(questionnaire_id: review_questionnaire_id)
    review_scores = {}
    # ACS Removed the if condition(and corressponding else) which differentiate assignments as team and individual assignments
    # to treat all assignments as team assignments

    response_maps = ResponseMap.where(reviewed_object_id: self.id, type: 'TeamReviewResponseMap')

    response_maps.each do |response_map|
      # Check if response is there
      corresponding_response = Response.where(map_id: response_map.id)
      respective_scores = {}
      respective_scores = review_scores[response_map.reviewer_id] if review_scores[response_map.reviewer_id].present?

      if corresponding_response.present?
        this_review_score_raw = Score.get_total_score(response: corresponding_response, questions: questions, q_types: [])
        this_review_score = ((this_review_score_raw * 100).round / 100.0) if this_review_score_raw >= 0.0
      else
        this_review_score = 0.0
      end
      respective_scores[response_map.reviewee_id] = this_review_score
      review_scores[response_map.reviewer_id] = respective_scores
    end
    review_scores
  end

  # Returns the average of all responses for this assignment as an integer (0-100)
  def get_average_score
    return 0 if get_total_reviews_assigned == 0
    sum_of_scores = 0
    self.response_maps.each do |response_map|
      if response_map.response
        sum_of_scores += response_map.response.get_average_score
      end
    end
    (sum_of_scores / get_total_reviews_completed).to_i
  end

  # parameterized by questionnaire
  def get_max_score_possible(questionnaire)
    sum_of_weights = questionnaire.questions.map(&:weight).sum
    max = questionnaire.questions * questionnaire.max_question_score * sum_of_weights
    [max, sum_of_weights]
  end

  def get_score_distribution
    distribution = Array.new(101, 0)

    self.response_maps.each do |response_map|
      if response_map.response.present?
        score = response_map.response.get_average_score.to_i
        distribution[score] += 1 if score.between?(0, 100)
      end
    end
    distribution
  end


  def get_scores(questions)
    scores = {}

    scores[:participants] = {}
    self.participants.each do |participant|
      scores[:participants][participant.id.to_s.to_sym] = participant.get_scores(questions)

      # for all quiz questionnaires (quizzes) taken by the participant
      # for all quiz questionnaires (quizzes) taken by the participant
      quiz_response_mappings = QuizResponseMap.where(reviewer_id: participant.id)
      quiz_responses = quiz_response_mappings.select(&:response).map(&:response)

      scores[:participants][participant.id.to_s.to_sym][:quiz] = {}
      scores[:participants][participant.id.to_s.to_sym][:quiz][:assessments] = quiz_responses
      scores[:participants][participant.id.to_s.to_sym][:quiz][:scores] = Score.compute_quiz_scores(scores[:participants][participant.id.to_s.to_sym][:quiz][:assessments])

      scores[:participants][participant.id.to_s.to_sym][:total_score] = compute_total_score(scores[:participants][participant.id.to_s.to_sym])
      scores[:participants][participant.id.to_s.to_sym][:total_score] += participant.compute_quiz_scores(scores[:participants][participant.id.to_s.to_sym])

    end
    #ACS Removed the if condition(and corresponding else) which differentiate assignments as team and individual assignments
    # to treat all assignments as team assignments
    scores[:teams] = {}
    index = 0
    self.teams.each do |team|
      scores[:teams][index.to_s.to_sym] = {}
      scores[:teams][index.to_s.to_sym][:team] = team

      if self.varying_rubrics_by_round?
        grades_by_rounds = {}

        total_score = 0
        total_num_of_assessments = 0    #calculate grades for each rounds
        for i in 1..self.get_review_rounds
          assessments = TeamReviewResponseMap.get_assessments_round_for(team,i)
          round_sym = ("review" + i.to_s).to_sym
          grades_by_rounds[round_sym]= Score.compute_scores(assessments, questions[round_sym])
          total_num_of_assessments += assessments.size
          if grades_by_rounds[round_sym][:avg].present?
            total_score += grades_by_rounds[round_sym][:avg] * assessments.size.to_f
          end
        end

        #merge the grades from multiple rounds
        scores[:teams][index.to_s.to_sym][:scores] = {}
        scores[:teams][index.to_s.to_sym][:scores][:max] = -999999999
        scores[:teams][index.to_s.to_sym][:scores][:min] = 999999999
        scores[:teams][index.to_s.to_sym][:scores][:avg] = 0
        for i in 1..self.get_review_rounds
          round_sym = ("review" + i.to_s).to_sym
          if(grades_by_rounds[round_sym][:max].present? && scores[:teams][index.to_s.to_sym][:scores][:max] < grades_by_rounds[round_sym][:max])
            scores[:teams][index.to_s.to_sym][:scores][:max] = grades_by_rounds[round_sym][:max]
          end
          if(grades_by_rounds[round_sym][:min].present? && scores[:teams][index.to_s.to_sym][:scores][:min] > grades_by_rounds[round_sym][:min])
            scores[:teams][index.to_s.to_sym][:scores][:min] = grades_by_rounds[round_sym][:min]
          end
        end

        if total_num_of_assessments.zero?
          scores[:teams][index.to_s.to_sym][:scores][:avg] = total_score / total_num_of_assessments
        else
          scores[:teams][index.to_s.to_sym][:scores][:avg] = 0
          scores[:teams][index.to_s.to_sym][:scores][:max] = 0
          scores[:teams][index.to_s.to_sym][:scores][:min] = 0
        end

      else
        assessments = TeamReviewResponseMap.get_assessments_for(team)
        scores[:teams][index.to_s.to_sym][:scores] = Score.compute_scores(assessments, questions[:review])
      end

      index += 1
    end
    scores
  end
end