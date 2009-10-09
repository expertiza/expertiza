class Score < ActiveRecord::Base
  belongs_to :question
  # Computes the total score for an assessment
  # params
  #  questionnaire_instance_id - specifies the rubric for which the total score is being calculated
  #  questionnaire - specifies the questionnaire 
  def self.get_total_score(questionnaire_instance_id, questionnaire)
    select = "SELECT SUM(s.score * q.weight) / (SUM(q.weight)*rs.max_question_score) * 100 as weighted_score "
    from = "FROM scores s, questions q, questionnaires rs "
    where = "WHERE s.question_id = q.id AND q.questionnaire_id = rs.id AND rs.id = #{questionnaire.id} AND s.instance_id = #{questionnaire_instance_id}"
    scores = Score.find_by_sql(select+from+where)
    return scores[0].weighted_score.to_f
  end
end
