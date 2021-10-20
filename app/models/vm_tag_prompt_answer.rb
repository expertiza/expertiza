class VmTagPromptAnswer
  def initialize(answer, tag_prompt, tag_dep)
    @answer = answer
    @tag_prompt = tag_prompt
    @tag_dep = tag_dep
  end

  attr_reader :answer

  attr_reader :tag_prompt

  attr_reader :tag_dep
end
