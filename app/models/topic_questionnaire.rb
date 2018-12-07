class TopicQuestionnaire < ActiveRecord::Base
  belongs_to :questionnaire
  belongs_to :sign_up_topics
end
