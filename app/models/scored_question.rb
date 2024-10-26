class ScoredQuestion < ChoiceQuestion
  validates :weight, presence: true # user must specify a weight for a item
  validates :weight, numericality: true # the weight must be numeric

  def edit; end

  def view_item_text; end

  def complete; end

  def view_completed_item; end

  def self.compute_item_score(response_id)
    answer = Answer.find_by(item_id: id, response_id: response_id)
    weight * answer.answer
  end
end
