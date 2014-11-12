class SurveyQuestionnaire < Questionnaire
    def after_initialize
      self.display_type = 'Survey' 
    end
end
