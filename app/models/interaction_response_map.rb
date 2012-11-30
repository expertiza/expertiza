class InteractionResponseMap < ResponseMap
  belongs_to :assignment, :class_name => 'Assignment', :foreign_key => 'reviewed_object_id'

  def questionnaire
    self.assignment.questionnaires.find_by_type('InteractionReviewQuestionnaire')
  end

  def get_title
    return "InteractionReview"
  end

end