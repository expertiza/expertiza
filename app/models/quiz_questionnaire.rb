class QuizQuestionnaire < Questionnaire
  attr_accessor :questionnaire
  after_initialize { post_initialization('Quiz') }

  def symbol
    'quiz'.to_sym
  end

  def get_assessments_for(participant)
    participant.quizzes_taken
  end

  def get_weighted_score(scores)
    compute_weighted_score(scores)
  end

  def compute_weighted_score(scores)
    if scores[:quiz][:scores][:avg]
      scores[:quiz][:scores][:avg] * 100 / 100.to_f
    else
      0
    end
  end

  def taken_by_anyone?
    !ResponseMap.where(reviewed_object_id: id, type: 'QuizResponseMap').empty?
  end

  def taken_by?(participant)
    !ResponseMap.where(reviewed_object_id: id, type: 'QuizResponseMap', reviewer_id: participant.id).empty?
  end
end
