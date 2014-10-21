class TeammateReviewQuestionnaire < Questionnaire
  after_initialize :post_initialization
  def post_initialization
    self.display_type = 'Teammate Review'
  end

  def symbol
    return "teammate".to_sym
  end

  def get_assessments_for(participant)
    time1 = Time.now
    puts "####################################     teammate_reviews Current Time1 : " + time1.inspect
    participant.teammate_reviews()
    # time2 = Time.now
    # puts "####################################     teammate_reviews Current Time2 : " + time2.inspect
  end


end
