class TeammateReviewQuestionnaire < Questionnaire
  after_initialize :post_initialization
  def post_initialization
    self.display_type = 'Teammate Review'
  end

  def symbol
    "teammate".to_sym
  end

  def get_assessments_for(participant)
    participant.teammate_reviews
  end
  
  def get_assessments_round_for(participant, round)
    team = AssignmentTeam.team(participant)
    return nil unless team

    responses = []
    if participant
      maps = ResponseMap.where(reviewee_id: participant, type: "TeammateReviewResponseMap")
      maps.each do |map|
        next if map.response.empty?
        map.response.each do |response|
          if response.round == round && response.is_submitted
            responses << response
          end
        end
      end
      # responses = Response.find(:all, :include => :map, :conditions => ['reviewee_id = ? and type = ?',participant.id, self.to_s])
      responses.sort! {|a, b| a.map.reviewer.fullname <=> b.map.reviewer.fullname }
    end
    responses
  end
  
end
