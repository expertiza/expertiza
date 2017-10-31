class AnswerTag < ActiveRecord::Base
  belongs_to :answer
  belongs_to :tag_prompts_deployment

  validates :answer_id, presence: true
  validates :tag_prompt_deployment_id, presence: true
  validates :value, presence: true
  validates :user_id, presence: true


  def tag_prompt()
    tag_dep = TagPromptDeployment.find(self.tag_prompt_deployment_id)
    tag_prompt = TagPrompt.find( tag_dep.tag_prompt_id)
    return tag_prompt
  end

  def tag_prompt_html_control()
    tag_dep = TagPromptDeployment.find(self.tag_prompt_deployment_id)
    tag_prompt = TagPrompt.find(tag_dep.tag_prompt_id)
    return tag_prompt.html_control(tag_dep, self.answer)
  end
end