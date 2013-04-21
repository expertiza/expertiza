module ResponseAnalytic
  #return score for all of the questions in an array
  def question_scores
    question_scores = Array.new
    self.scores.each do |score|
      question_scores << score.score
    end
    question_scores
  end

end