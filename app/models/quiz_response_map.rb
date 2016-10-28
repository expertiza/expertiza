class QuizResponseMap < ResponseMap
  belongs_to :reviewee, class_name: 'Participant', foreign_key: 'reviewee_id'
  belongs_to :contributor, class_name: 'Participant', foreign_key: 'reviewee_id'
  belongs_to :quiz_questionnaire, class_name: 'QuizQuestionnaire', foreign_key: 'reviewed_object_id'
  belongs_to :assignment, class_name: 'Assignment'
  has_many :quiz_responses, foreign_key: :map_id

  def questionnaire
    self.quiz_questionnaire
  end

  def get_title
    "Quiz"
  end

  def delete
    self.response.delete unless self.response.nil?
    self.destroy
  end

  def self.get_mappings_for_reviewer(participant_id)
    QuizResponseMap.where(reviewer_id: participant_id)
  end

  def quiz_score
    questions = Question.where(questionnaire_id: self.reviewed_object_id) # for quiz response map, the reivewed_object_id is questionnaire id
    quiz_score = 0.0
    response_id = self.response.first.id rescue nil

    return 'N/A' if response_id.nil? # this quiz has not been taken yet

    questions.each do |question|
      score = Answer.where(response_id: response_id, question_id:  question.id).first
      if score.nil?
        # The quiz has been taken but not all the answers are stored correctly.
        return 'N/A'
      else
        quiz_score += score.answer
      end
    end

    question_count = questions.length

    (quiz_score / question_count * 100).round(1)
  end
end
