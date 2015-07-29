class CheckBox < UnscoredQuestion
  def edit
  end

  def view_question_text
  end

  def view_completed_question
  end

  def complete
  end

  def self.selected_answer
    answer = Answer.where(question_id: self.id)
    if answer.comment == '0'
       return 'Unchecked'
    else 
       return 'Checked'
    end
  end
end
