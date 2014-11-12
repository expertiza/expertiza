class ReviewQuestionnaire < Questionnaire
  def after_initialize
    self.display_type = 'Review'   
  end  
  
  def symbol
    return "review".to_sym
  end
  
  def get_assessments_for(participant)
    participant.get_reviews()  
  end

  # return  the responses for specified round, for varying rubric feature -Yang
  def get_assessments_round_for(participant,round)
    team_id =AssignmentTeam.get_team(participant).id
    responses = Array.new
    if participant
      maps = ResponseMap.find(:all, :conditions => ['reviewee_id = ? and type = ? and round=?',team_id,"TeamReviewResponseMap", round])
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
