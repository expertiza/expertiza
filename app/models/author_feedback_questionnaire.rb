class AuthorFeedbackQuestionnaire < Questionnaire
  after_initialize :post_initialization
  def post_initialization
    self.display_type = 'Author Feedback'
  end

  def symbol
    return "feedback".to_sym
  end

  def get_assessments_for(participant)
    time1 = Time.now
    puts "####################################     get_assessments_for Current Time1 : " + time1.inspect
    participant.feedback()
  end


end
