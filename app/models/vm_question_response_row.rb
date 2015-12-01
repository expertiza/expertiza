class VmQuestionResponseRow

  def initialize(questionText, question_id, weight)
    @questionText = questionText
    @question_id = question_id
    @weight = weight
    @score_row = Array.new
  end

  def questionText
    @questionText
  end

  def question_id
    @question_id
  end

  def score_row
    @score_row
  end

  def weight
    @weight
  end

end