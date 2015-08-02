class TextResponse < Question
  validates_presence_of :size
  
  def edit
  end

  def view_question_text
  end

  def complete
  end

  def view_completed_question
  end
end
