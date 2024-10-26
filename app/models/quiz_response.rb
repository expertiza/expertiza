class QuizResponse < Response
  belongs_to :assignment
  belongs_to :itemnaire
  belongs_to :item
  belongs_to :participant
  belongs_to :response_map, foreign_key: :map_id, inverse_of: false
  belongs_to :quiz_response_map, foreign_key: :map_id, inverse_of: false

  # validates :response, :presence => true
end
