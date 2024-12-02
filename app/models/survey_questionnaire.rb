class SurveyQuestionnaire < Questionnaire
  after_initialize { post_initialization('Survey') }
end
