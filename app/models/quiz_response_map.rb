class QuizResponseMap < ResponseMap
  belongs_to :quiz_questionnaire, :class_name => 'QuizQuestionnaire', :foreign_key => 'reviewed_object_id'

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