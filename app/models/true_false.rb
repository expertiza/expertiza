class TrueFalse < QuizQuestion
  has_many :quiz_question_choices, :class_name => 'QuizQuestionChoice', :foreign_key => 'question_id'

  def edit(count)

  end

  def complete(count, answer=nil)

  end

  def view_completed_question(count, answer)

  end
end