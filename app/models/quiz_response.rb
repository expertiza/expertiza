class QuizResponse < ActiveRecord::Base
  belongs_to :assignment
  belongs_to :questionnaire
  belongs_to :question

  validates :response, :presence => true
end
