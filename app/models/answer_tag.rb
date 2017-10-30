class AnswerTag < ActiveRecord::Base
  belongs_to :answer
  belongs_to :tag_prompt_deployment
  belongs_to :user
end
