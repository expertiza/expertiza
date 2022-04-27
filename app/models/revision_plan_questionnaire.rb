class RevisionPlanQuestionnaire < Questionnaire
  has_one :revision_plan_team_map, foreign_key: 'questionnaire_id', dependent: :destroy
  after_initialize :post_initialization
  @print_name = "Revision Plan Rubric"

  class << self
    attr_reader :print_name
  end

  def post_initialization
    self.display_type = 'Revision Plan'
  end

  def symbol
    "revisionplan".to_sym
  end

  def self.get_questionnaire_for_current_round(team_id)
    assignment_team = Team.find(team_id)
    assignment = assignment_team.assignment
    current_round = assignment.number_of_current_round(assignment_team.topic)
    questionnaire = RevisionPlanTeamMap.find_by(team: assignment_team, used_in_round: current_round).try(:questionnaire)
    unless questionnaire
      questionnaire = RevisionPlanQuestionnaire.new
      questionnaire.name = 'Revision Plan Questionnaire'
      questionnaire.instructor_id = assignment.instructor_id
      questionnaire.max_question_score = 5
      questionnaire.save
      @questionnaire_team_map = RevisionPlanTeamMap.create(team_id: assignment_team.id, used_in_round: current_round, questionnaire_id: questionnaire.id)
    end
    return questionnaire
  end

  def team
    revision_plan_team_map.team
  end

  # Display questionnaire heading in response view
  def display_heading?
    return true
  end

  # Return true if user owns questionnaire
  def owner?(user_id)
    questionnaire.team.users.map { |u| u.id }.include?(user_id) || super
  end
end
