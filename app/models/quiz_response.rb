class QuizResponse < Response
  attr_accessor :response_maps
  belongs_to :assignment
  belongs_to :questionnaire
  belongs_to :question
  belongs_to :participant
<<<<<<< HEAD
  belongs_to :response_map, foreign_key: :map_id, inverse_of: false
  belongs_to :quiz_response_map, foreign_key: :map_id, inverse_of: false
=======
  belongs_to :response_map, foreign_key: :map_id, inverse_of: :quiz_responses
  belongs_to :quiz_response_map, foreign_key: :map_id, inverse_of: :quiz_responses
>>>>>>> Rahul and Shraddha Code Climate Fixes

  # validates :response, :presence => true
end
