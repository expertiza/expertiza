class QuizResponseMap < ResponseMap
  belongs_to :reviewee, :class_name => 'Participant', :foreign_key => 'reviewee_id'
  belongs_to :assignment, :class_name => 'Assignment', :foreign_key => 'reviewed_object_id'
  belongs_to :contributor, :class_name => 'Participant', :foreign_key => 'reviewee_id'
  
  def questionnaire
    Questionnaire.find(self.reviewee.quiz_id)
  end

  def get_title
    return "Quiz"
  end

  
end
