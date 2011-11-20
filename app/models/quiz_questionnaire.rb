class QuizQuestionnaire < Questionnaire
    def after_initialize
      self.display_type = 'Quiz'
    end

    def symbol
      return "quiz".to_sym
    end

    def get_assessments_for(participant)
      participant.get_quiz()
    end

    def get_weighted_score(assignment, scores)
      return compute_weighted_score(self.symbol, assignment, scores)
    end

end