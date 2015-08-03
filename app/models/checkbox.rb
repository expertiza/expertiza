class Checkbox < UnscoredQuestion


  def view_question_text
    ''
  end

  def complete
    ''
  end

  def view_completed_question(response_id)
    ''
  end

  def self.checked?(response_id)
    answer = Answer.where(question_id: self.id, response_id: response_id).first
    return answer.comment == '0'
  end
end
