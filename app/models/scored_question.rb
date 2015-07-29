class ScoredQuestion < ChoiceQuestion
  def self.compute_question_score
     answer = Answer.where(question_id: self.id)
     return self.weight * answer.answer
  end
end
