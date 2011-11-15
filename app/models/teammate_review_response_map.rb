<<<<<<< HEAD
<<<<<<< HEAD
class TeammateReviewResponseMap < ResponseMap
  belongs_to :reviewee, :class_name => 'Participant', :foreign_key => 'reviewee_id'
  belongs_to :assignment, :class_name => 'Assignment', :foreign_key => 'reviewed_object_id'
  
  def questionnaire
    self.assignment.questionnaires.find_by_type('TeammateReviewQuestionnaire')
  end  
  
  def contributor
    nil
  end
  
  def get_title
    return "Teammate Review"
  end  
=======
class TeammateReviewResponseMap < ResponseMap
  belongs_to :reviewee, :class_name => 'Participant', :foreign_key => 'reviewee_id'
  belongs_to :assignment, :class_name => 'Assignment', :foreign_key => 'reviewed_object_id'
  
  def questionnaire
    self.assignment.questionnaires.find_by_type('TeammateReviewQuestionnaire')
  end  
  
  def contributor
    nil
  end
  
  def get_title
    return "Teammate Review"
  end  
>>>>>>> c4cd6ee2acd0c2721114a9165e8bf6050a7dd1ee
=======
class TeammateReviewResponseMap < ResponseMap
  belongs_to :reviewee, :class_name => 'Participant', :foreign_key => 'reviewee_id'
  belongs_to :assignment, :class_name => 'Assignment', :foreign_key => 'reviewed_object_id'
  
  def questionnaire
    self.assignment.questionnaires.find_by_type('TeammateReviewQuestionnaire')
  end  
  
  def contributor
    nil
  end
  
  def get_title
    return "Teammate Review"
  end  
>>>>>>> c4cd6ee2acd0c2721114a9165e8bf6050a7dd1ee
end