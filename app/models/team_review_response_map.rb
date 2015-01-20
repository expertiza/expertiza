class TeamReviewResponseMap < ReviewResponseMap
  belongs_to :reviewee, :class_name => 'Team', :foreign_key => 'reviewee_id'
  belongs_to :contributor, :class_name => 'Team', :foreign_key => 'reviewee_id'

  # if this assignment uses "varying rubrics" feature, the "used_in_round" field should not be nil
  # so find the round # from response_map, and use that round # to find corresponding questionnaire_id from assignment_questionnaires table
  # otherwise this assignment does not use the "varying rubrics", so in assignment_questionnaires table there should
  # be only 1 questionnaire with type 'ReviewQuestionnaire'.    -Yang
  def questionnaire
    round = self.round
    if round==nil              #for assignment without varying rubrics
      return self.assignment.questionnaires.find_by_type('ReviewQuestionnaire')
    else
      assignment_id = self.assignment.id
      questionnaire_id= AssignmentQuestionnaire.find_by_assignment_id_and_used_in_round(assignment_id,round).questionnaire_id
      return self.assignment.questionnaires.find_by_id(questionnaire_id)
    end
  end

  # return  the responses for specified round, for varying rubric feature -Yang
  def self.get_assessments_round_for(team,round)
    team_id =team.id
    responses = Array.new
    if team_id
      maps = ResponseMap.where(:reviewee_id => team_id, :type => "TeamReviewResponseMap", :round => round)
      maps.each{ |map|
        if map.response
          responses << map.response
        end
      }
      responses.sort! {|a,b| a.map.reviewer.fullname <=> b.map.reviewer.fullname }
    end
    return responses
  end
end
