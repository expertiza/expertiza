class MetareviewQuestionnaire < Questionnaire
  after_initialize :post_initialization
  attr_accessible :name, :instructor_id, :private, :min_question_score, :max_question_score, :type, :display_type
  
  def post_initialization
    self.display_type = 'Metareview'
  end

  def symbol
    "metareview".to_sym
  end

  def get_assessments_for(participant)
    participant.metareviews
  end
end
