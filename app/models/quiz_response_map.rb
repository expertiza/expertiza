class QuizResponseMap < ResponseMap
  belongs_to :reviewee, :class_name => 'Participant', :foreign_key => 'reviewee_id'
  belongs_to :contributor, :class_name => 'Participant', :foreign_key => 'reviewee_id'
  belongs_to :quiz_questionnaire, :class_name => 'QuizQuestionnaire', :foreign_key => 'reviewed_object_id'
  belongs_to :assignment, :class_name => 'Assignment'

  def questionnaire
    self.quiz_questionnaire
  end

  def get_title
    return "Quiz"
  end

  def delete
    if self.response != nil
      self.response.delete
    end
    self.destroy
  end
end