class QuizResponse < Response
  belongs_to :assignment
  belongs_to :questionnaire
  belongs_to :question
  belongs_to :participant
  belongs_to :response_map

  validates :response, :presence => true
end
