class UnscoredQuestion < ChoiceQuestion
  def self.selected_answer
    answer = Answer.where(question_id: self.id)
    return self.txt.split('|')[answer.answer]
  end
end
