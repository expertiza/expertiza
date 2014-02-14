class ScoreView < ActiveRecord::Base
  attr_accessible :sum_of_weights,:question_weight, :q_id,:q_type,:q_parameters,:q_question_id,:q1_id,:q1_name,:q1_instructor_id,:q1_private,
    :q1_min_question_score, :q1_max_question_score,:q1_created_at,:q1_updated_at,:q1_default_num_choices,
    :q1_type,:q1_display_type,:q1_section,:q1_instruction_loc,:ques_id,:ques_questionnaire_id, :s_id,:s_question_id,
    :s_score,:s_comments,:s_response_id,:sum_of_weights,:weighted_score
  def readonly?
    true
  end
end
