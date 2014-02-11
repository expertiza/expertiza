class ReviewQuestionnaire < Questionnaire
  after_initialize :post_initialization
def post_initialization
    self.display_type = 'Review'   
  end  
  
  def symbol
    return "review".to_sym
  end
  
  def get_assessments_for(participant)
    participant.reviews()
  end  
  

end
