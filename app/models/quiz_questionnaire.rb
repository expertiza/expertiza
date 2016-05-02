class QuizQuestionnaire < Questionnaire
  has_many :quiz_questions, class_name: 'QuizQuestion', foreign_key: :questionnaire_id

  after_initialize :post_initialization
  def post_initialization
    self.display_type = 'Quiz'
  end

  def symbol
    return "quiz".to_sym
  end

  def get_assessments_for(participant)
    participant.quizzes_taken()
  end

  def get_weighted_score(scores)
    return compute_weighted_score(scores)
  end

  def compute_weighted_score(scores)
    if scores[:quiz][:scores][:avg]
      #dont bracket and to_f the whole thing - you get a 0 in the result.. what you do is just to_f the 100 part .. to get the fractions
      return scores[:quiz][:scores][:avg] * 100  / 100.to_f
      else
        return 0
      end
    end

  def taken_by_anyone?
    !ResponseMap.where(reviewed_object_id: self.id, type: 'QuizResponseMap').empty?
  end

  def taken_by? participant
    !ResponseMap.where(reviewed_object_id: self.id, type: 'QuizResponseMap', reviewer_id: participant.id).empty?
  end

  end
