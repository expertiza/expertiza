class ReviewQuestionnaire < Questionnaire
  @print_name = 'Review Rubric'

  after_initialize { post_initialization('Review') }
  def symbol; super('review'); end
  def get_assessments_for(participant); super(participant, :reviews); end

  class << self
    attr_reader :print_name
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
      responses.sort! { |a, b| a.map.reviewer.fullname <=> b.map.reviewer.fullname }
    end
    responses
  end
end
