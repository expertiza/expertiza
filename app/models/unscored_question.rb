class UnscoredQuestion < ChoiceQuestion
  validates_presence_of :alternatives
  
  def edit
  end

  def view_question_text
  end

  def complete
  end

  def view_completed_question
  end
end
