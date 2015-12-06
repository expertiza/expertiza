#represents each row of a heatgrid-table, which is represented by the vm_question_response class.
class VmQuestionResponseRow

  def initialize(score_value, color_code, comments)
    @score_value = score_value
    @color_code = color_code
    @comment = comments
  end

  def score_value
    @score_value
  end

  def comment
    @comment
  end

  def color_code
    @color_code
  end
end