class QuizQuestion < Question
  has_many :quiz_question_choices, class_name: 'QuizQuestionChoice', foreign_key: 'question_id'
  def edit
  end

  def view_question_text
  end

  def complete
  end

  def view_completed_question
  end
end
