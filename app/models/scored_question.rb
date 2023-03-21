class ScoredQuestion < ChoiceQuestion
  validates :weight, presence: true # user must specify a weight for a question
  validates :weight, numericality: true # the weight must be numeric

  def edit; end

  def view_question_text; end

  def complete; end

  def view_completed_question; end

  def self.compute_question_score(response_id)
    answer = Answer.find_by(question_id: id, response_id: response_id)
    weight * answer.answer
  end
end
