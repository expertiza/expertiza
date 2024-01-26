# represents each score cell of the heatgrid table.
class VmQuestionResponseScoreCell
  def initialize(score_value, color_code, comments, vmprompts = nil)
    @score_value = score_value
    @color_code = color_code
    @comment = comments
    @vm_prompts = vmprompts
  end

  attr_reader :score_value

  attr_reader :comment

  attr_reader :color_code

  attr_reader :vm_prompts
end
