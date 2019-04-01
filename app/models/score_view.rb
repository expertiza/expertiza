class ScoreView < ActiveRecord::Base
  attr_accessible :question_weight, :type, :q1_id, :q1_name, :q1_instructor_id, :q1_private, :q1_min_question_score, :q1_max_question_score, :s_response_id,
                  :q1_created_at, :q1_updated_at, :q1_type, :q1_display_type, :ques_id, :ques_questionnaire_id, :s_id, :s_question_id, :s_score, :s_comments
  def readonly?
    true
  end
end
