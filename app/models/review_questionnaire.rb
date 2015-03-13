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

  # return  the responses for specified round, for varying rubric feature -Yang
  def get_assessments_round_for(participant,round)
    team=AssignmentTeam.get_team(participant)
    return nil if !team

    team_id = team.id
    responses = Array.new
    if participant
      maps = ResponseMap.where(:reviewee_id => team_id, :type => "TeamReviewResponseMap", :round => round)
      maps.each{ |map|
        if map.response
          responses << map.response
        end
      }
      #responses = Response.find(:all, :include => :map, :conditions => ['reviewee_id = ? and type = ?',participant.id, self.to_s])
      responses.sort! {|a,b| a.map.reviewer.fullname <=> b.map.reviewer.fullname }
    end
    return responses
  end

end