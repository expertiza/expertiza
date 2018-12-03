class RevisionReviewQuestionnaire < Questionnaire
  attr_accessible :id, :name, :instructor_id, :private, :min_question_score, :max_question_score,
                  :type, :display_type, :instruction_loc, :submission_record_id, :created_at, :updated_at,
                  :print_name

  after_initialize :post_initialization
  @print_name = 'Revision Review Rubric'

  class << self
    attr_reader :print_name
  end

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

    maps = ResponseMap.where(reviewee_id: team.id, type: "ReviewResponseMap")
    responses = maps.reject {|r| r.response.empty? }.flat_map(&:response)
    responses.select(&:is_submitted).sort_by {|r| r.map.reviewer.fullname }
  end
end
