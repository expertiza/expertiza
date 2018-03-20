class ScoredQuestion < ChoiceQuestion
  validates :weight, presence: true # user must specify a weight for a question
  validates :weight, numericality: true # the weight must be numeric

  #attr_accessible :id, :txt, :weight, :questionnaire_id, :seq, :size,
  #                :alternatives, :break_before, :max_label, :min_label, :questionnaire, :type

  def edit; end

  def view_question_text; end

  def complete; end

  def view_completed_question; end

  def self.compute_question_score(response_id)
    answer = Answer.where(question_id: self.id, response_id: response_id).first
    self.weight * answer.answer
  end
end
