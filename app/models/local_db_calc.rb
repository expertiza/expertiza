# E1731 changes: New file. Not yet finished with the implementation
module LocalDbCalc
  def self.compute_total_score(assignment, scores)
    total = 0

    teams = AssignmentTeam.where(parent_id: assignment.id)
    teams.each { |team|
      response_maps = team.review_mappings
      response_maps.each { |map| total += LocalDbScore.where(response_map_id: map.id).pluck(:score) }
    }

    total
  end

  # To be modified
  def self.store_total_scores(assignment)
    raise RuntimeError, "Assignment #{assignment.id} #{assignment.name}"

#    teams = AssignmentTeam.where(parent_id: assignment.id)

#    assignment.questionnaires.each { |questionnaire|
#      round = AssignmentQuestionnaire.find_by_assignment_id_and_questionnaire_id(assignment.id, questionnaire.id).used_in_round
#      questionnaire_symbol = if !round.nil?
#                               (questionnaire.symbol.to_s + round.to_s).to_sym
#                             else
#                               questionnaire.symbol
#                             end

#      aq = questionnaire.assignment_questionnaires.find_by_assignment_id(assignment.id)
#      score = 0
#      if !scores[symbol][:scores][:avg].nil?
#        score = scores[symbol][:scores][:avg] * aq.questionnaire_weight / 100.0
#      end

#      response_map_id = ResponseMap.where(reviewee_id: assignment.id).pluck(:id)

#      if(LocalDbScore.where(response_map_id: response_map_id, round: round).nil?)
#        LocalDbScore.create(review_type: "ReviewLocalDBScore", round: round, score: score, response_map_id: reference_id)
#      else
#        LocalDbScore.update # add score
#      end
#    }

  end
end
