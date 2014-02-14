class Assignment_scores
  def initialize(assignment)
    @assignment = assignment
  end

  def scores
    #get score summary for a particular assignment
    result = ParticipantScoreView.find_by_sql(['SELECT temp_scores.team_id,temp.questionaire_type,AVG(score) avg_score, MIN(score) min_score, MAX(score) max_score FROM
                                               (SELECT (SUM(score * weight)*100/ (SUM(weight) * max_question_score))score,questionaire_type,team_id
                                                FROM participant_score_views WHERE assignment_id = ? GROUP BY response_id) temp_scores GROUP BY team_id,questionaire_type',@assignment.id]);
                                                return result
  end

end
