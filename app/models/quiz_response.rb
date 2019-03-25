class QuizResponse < Response
  attr_accessor :response_maps
  belongs_to :assignment
  belongs_to :questionnaire
  belongs_to :question
  belongs_to :participant
  belongs_to :response_map, foreign_key: :map_id, inverse_of: :quiz_responses
  belongs_to :quiz_response_map, foreign_key: :map_id, inverse_of: :quiz_responses

  # validates :response, :presence => true
end
