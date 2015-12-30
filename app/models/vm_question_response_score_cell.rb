#represents each score cell of the heatgrid table.
class VmQuestionResponseScoreCell

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
