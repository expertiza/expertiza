class QuizResponse < ActiveRecord::Base
  belongs_to :assignment
  belongs_to :questionnaire
  belongs_to :question
  belongs_to :participant

  validates :response, :presence => true
end
