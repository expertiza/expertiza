class ScoredQuestion < ChoiceQuestion
  validates_presence_of :weight # user must specify a weight for a question
  validates_numericality_of :weight # the weight must be numeric

  def edit
  end

  def view_question_text
  end

  def complete
  end

  def view_completed_question
  end

  def self.compute_question_score(response_id)
     answer = Answer.where(question_id: self.id, response_id: response_id).first
     return self.weight * answer.answer
  end
end
