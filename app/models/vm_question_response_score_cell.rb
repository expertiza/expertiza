# represents each score cell of the heatgrid table.
class VmQuestionResponseScoreCell
  def initialize(score_value, color_code, comments, alltags=nil)
    @score_value = score_value
    @color_code = color_code
    @comment = comments
    @tags = alltags
  end

  attr_reader :score_value

  attr_reader :comment

  attr_reader :color_code

  attr_reader :tags
end
