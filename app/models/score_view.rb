class ScoreView < ApplicationRecord
  # setting this to false so that factories can be created
  # to test the grading of weighted quiz questionnaires
  def readonly?
    false
  end

  def self.questionnaire_data(questionnaire_id, response_id)
    questionnaire_data = ScoreView.find_by_sql ["SELECT q1_max_question_score ,SUM(question_weight) as sum_of_weights,SUM(question_weight * s_score) as weighted_score FROM score_views WHERE type in('Criterion', 'Scale') AND q1_id = ? AND s_response_id = ?", questionnaire_id, response_id]
    questionnaire_data[0]
  end
end
