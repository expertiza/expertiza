class AnswerTag < ActiveRecord::Base
  belongs_to :answer
  belongs_to :tag_prompts_deployment

  validates :answer_id, presence: true
  validates :tag_prompt_deployment_id, presence: true
  validates :value, presence: true
  validates :user_id, presence: true

  def tag_prompt
    tag_dep = TagPromptDeployment.find(self.tag_prompt_deployment_id)
    tag_prompt = TagPrompt.find(tag_dep.tag_prompt_id)
    tag_prompt
  end

  def tag_prompt_html_control user_id
    tag_dep = TagPromptDeployment.find(self.tag_prompt_deployment_id)
    tag_prompt = TagPrompt.find(tag_dep.tag_prompt_id)
    tag_prompt.html_control(tag_dep, self.answer, user_id)
  end
end
