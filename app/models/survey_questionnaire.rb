class SurveyQuestionnaire < Questionnaire
  def assign_participants end

  # Different methods for different statistics
  def generate_statistics_no_of_responses end

  def generate_statistics_t_test_score end

  after_initialize :post_initialization
  def post_initialization
    self.display_type = 'Survey'
  end
end
