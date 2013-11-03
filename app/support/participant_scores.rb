class ParticipantScores

  def initialize(participant)
    @participant =  participant
  end
  def score_summary
 result = ParticipantScoreView.find_by_sql(['SELECT temp.questionaire_type,AVG(score) avg_score, MIN(score) min_score, MAX(score) max_score FROM
(SELECT (SUM(score * weight)*100/ (SUM(weight) * max_question_score))score,questionaire_type
 FROM participant_score_views WHERE reviewee_id = ? GROUP BY response_id) temp GROUP BY questionaire_type',@participant.id] )
 return  result
  end

  def score_for_review(response_type)
      result =  ParticipantScoreView.find_by_sql(['SELECT * FROM participant_score_views WHERE questionaire_type = ? AND reviewee_id = ?',response_type,@participant.id])
      return result
  end


end