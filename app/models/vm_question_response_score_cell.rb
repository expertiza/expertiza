# represents each score cell of the heatgrid table.
class VmQuestionResponseScoreCell
  def initialize(score_value, color_code, comments, vmprompts = nil, response_id)
    @score_value = score_value
    @color_code = color_code
    @comment = comments
    @vm_prompts = vmprompts
    @response_id = response_id
  end

  attr_reader :score_value
  def reviewer_id
    resp = Response.find(@response_id)
    map = ResponseMap.find(resp.map_id)
    map.reviewer_id
  end

  attr_reader :comment

  attr_reader :color_code

  attr_reader :vm_prompts
end
