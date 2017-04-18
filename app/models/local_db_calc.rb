module LocalDbCalc
  def get_total_scores
    reference_id = ResponseMap.where(reviewee_id: self.id).pluck(:id)
    total = LocalDbScore.find_by_response_map(reference_id)
  end

  def store_total_scores(scores)
    total = 0
    self.questionnaires.each {|questionnaire| total += questionnaire.get_weighted_score(self, scores) }

    reference_id = ResponseMap.where(reviewee_id: self.id).pluck(:id)
    round = AssignmentQuestionnaire.find_by_assignment_id_and_questionnaire_id(self.id, self.questionnaires[0].id).used_in_round
    LocalDbScore.create(type: "ReviewLocalDBScore", round: round, score: total, response_map_id: reference_id)
  end
end