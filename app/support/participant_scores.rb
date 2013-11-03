class ParticipantScores

  def initialize(participant)
    @participant =  participant
  end
  def score_summary
    scores = Hash.new
    result = ParticipantScoreView.find_by_sql(['SELECT SUM(score * weight) weighted_score, SUM(weight) sum_of_weights,questionaire_type as questionaire_type, max_question_score as max_question_score
 FROM participant_score_views WHERE reviewee_id = ? GROUP BY response_id',@participant.id] )
=begin
    score_holder = Hash.new
    scores[:max] = -999999999
    scores[:min] = 999999999
    scores[:avg] = 0
    total_score = 0
    curr_score = 0
    i = 0
    result.each {
      |score|
      if score_holder[questionaire_type].nil?
        score_holder[questionaire_type] = 0
      end
        curr_score = (score.weighted_score.to_f / ( score.sum_of_weights.to_f * score[:max_question_score].to_f)) * 100
      if(curr_score > scores[:max])
        scores[:max] = curr_score
      end
      if(curr_score < scores[:min])
        scores[:min] = curr_score
      end
      total_score += curr_score
      i += 1
      puts   curr_score
      score_holder[questionaire_type] +=  curr_score
    }
    scores[:avg] = total_score / i
    puts scores
=end
  end
end