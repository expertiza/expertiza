class Score < ActiveRecord::Base
  belongs_to :question
  # Computes the total score for an assessment
  # params
  #  questionnaire_instance_id - specifies the rubric for which the total score is being calculated
  #  questionnaire - specifies the questionnaire
  #  questions - specifies the questions associated with a questionnaire 
  #  total_weight -  the total weight of questions in the questionnaire
  def self.get_total_score(questionnaire_instance_id, questionnaire, total_weight)  
    scores = Score.find_by_sql("select * from scores where instance_id = "+questionnaire_instance_id.to_s+" and questionnaire_type_id= "+questionnaire.type_id.to_s)
    weighted_score_sum = 0
    i = 0
    scores.each{
      |item|                    
      weighted_score_sum += item.score * item.question.weight
      i += 1
    }   
    return (weighted_score_sum.to_f / total_weight.to_f) / questionnaire.max_question_score.to_f * 100.00
  end
end
