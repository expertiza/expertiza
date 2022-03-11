class ScoredQuestion < ChoiceQuestion
  validates :weight, presence: true # user must specify a weight for a question
  validates :weight, numericality: true # the weight must be numeric

  DEFAULT_MAX_AGREEMENT = 'Strongly agree'.freeze # Default maximum agreement for scored questions
  DEFAULT_MIN_AGREEMENT = 'Strongly disagree'.freeze # Default minimum agreement for scored questions
  DEFAULT_ALTERNATIVES = '0|1|2|3|4|5'.freeze # Default alternatives for dropdown questions
  DEFAULT_CRITERION_SIZE = '50, 3'.freeze # Default size for Criterion and Cake questions
  DEFAULT_TEXT_FIELD_SIZE = '30'.freeze # Default size for a TextField question
  DEFAULT_TEXT_AREA_SIZE = '60, 5'.freeze # Default size for a TextArea question
  def edit; end

  def view_question_text; end

  def complete; end

  def view_completed_question; end

  def self.compute_question_score(response_id)
    answer = Answer.find_by(question_id: id, response_id: response_id)
    weight * answer.answer
  end
end
