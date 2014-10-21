class MetareviewQuestionnaire < Questionnaire
  after_initialize :post_initialization
  def post_initialization
    self.display_type = 'Metareview'
  end

  def symbol
    return "metareview".to_sym
  end

  def get_assessments_for(participant)
    time1 = Time.now
    puts "####################################     metareviews Current Time1 : " + time1.inspect
    participant.metareviews()
  end


end
