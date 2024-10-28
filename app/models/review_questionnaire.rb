class ReviewQuestionnaire < Questionnaire
  after_initialize :post_initialization
  @print_name = 'Review Rubric'

  class << self
    attr_reader :print_name
  end

  def post_initialization
    self.display_type = 'Review'
  end

  def symbol
    'review'.to_sym
  end

  def get_assessments_for(participant)
    participant.reviews
  end

  # return  the responses for specified round, for varying rubric feature -Yang
  def get_assessments_round_for(participant, round)
    team = AssignmentTeam.team(participant)
    return nil unless team

    team_id = team.id
    responses = []
    if participant
      maps = ResponseMap.where(reviewee_id: team_id, type: 'ReviewResponseMap')
      maps.each do |map|
        next if map.response.empty?

        map.response.each do |response|
          responses << response if response.round == round && response.is_submitted
        end
      end
      # responses = Response.find(:all, :include => :map, :conditions => ['reviewee_id = ? and type = ?',participant.id, self.to_s])
      responses.sort! { |a, b| a.map.reviewer.name <=> b.map.reviewer.name }
    end
    responses
  end
end
