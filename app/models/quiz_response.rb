class QuizResponse < Response
  belongs_to :assignment
  belongs_to :questionnaire
  belongs_to :question
  belongs_to :participant
  belongs_to :response_map, foreign_key: :map_id
  belongs_to :quiz_response_map, foreign_key: :map_id

  validates :response, :presence => true
end
