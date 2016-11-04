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
    self.weight * answer.answer
  end

  def question_min_to_max(answer = nil, questionnaire_min, questionnaire_max)
    (questionnaire_min..questionnaire_max).each do |j|
      html = '<td width="10%"><input type="radio" id="' + j.to_s + '" value="' + j.to_s + '" name="Radio_' + self.id.to_s + '"'
      html += 'checked="checked"' if (!answer.nil? and answer.answer == j) or (answer.nil? and questionnaire_min == j)
      html += '></td>'
      html
    end
  end
end

