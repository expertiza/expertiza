# represents each score cell of the heatgrid table.
class VmQuestionResponseScoreCell
  def initialize(score_value, color_code, comments, is_instructor_review, vmprompts = nil)
    @score_value = score_value
    @color_code = color_code
    @comment = comments
    @vm_prompts = vmprompts
    @is_instructor_review = is_instructor_review
  end

  attr_reader :score_value

  attr_reader :comment

  attr_reader :color_code

  attr_reader :vm_prompts
 attr_reader :is_instructor_review
end
