class AssignmentSurveyQuestionnaire < SurveyQuestionnaire
  after_initialize :post_initialization
  @@print_name = "Assignment Survey"

  def self.print_name
    @@print_name
  end

  def post_initialization
    self.display_type = 'Assignment Survey'
  end
end
