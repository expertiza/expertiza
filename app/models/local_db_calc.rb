# E1731 changes: New file. Not yet finished with the implementation
module LocalDbCalc
  def fetch_total_scores
    reference_id = ResponseMap.where(reviewee_id: self.id).pluck(:id)
    total = LocalDbScore.where(response_map_id: reference_id).pluck(:score)
  end

  def store_total_scores(scores)
    total = 0
    self.questionnaires.each { |questionnaire|
      #round = AssignmentQuestionnaire.find_by_assignment_id_and_questionnaire_id(self.id, questionnaire.id).used_in_round
       total += questionnaire.get_weighted_score(self, scores) }

    reference_id = ResponseMap.where(reviewee_id: self.id).pluck(:id)
    round = AssignmentQuestionnaire.find_by_assignment_id_and_questionnaire_id(self.id, self.questionnaires[0].id).used_in_round
    LocalDbScore.create(review_type: "ReviewLocalDBScore", round: round, score: total, response_map_id: reference_id)
  end
end