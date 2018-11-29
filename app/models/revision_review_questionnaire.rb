class RevisionReviewQuestionnaire < Questionnaire
  after_initialize :post_initialization

  def post_initialization
    self.display_type = "Review"
  end

  def symbol
    "review".to_sym
  end

  # return the responses for round 2, for varying rubric feature - Yang, Iyer
  def get_assessments_round_for(participant)
    team = AssignmentTeam.team(participant)
    return nil unless team
    return [] if participant.nil?

    maps = ResponseMap.where(reviewee_id: team.id, type: "RevisionReviewResponseMap")
    responses = maps.reject {|r| r.response.empty? }.flat_map(&:response)
    responses.select(&:is_submitted).sort_by {|r| r.map.reviewer.fullname }
  end
end
