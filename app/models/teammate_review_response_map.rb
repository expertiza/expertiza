class TeammateReviewResponseMap < ResponseMap
  belongs_to :reviewee, class_name: 'Participant', foreign_key: 'reviewee_id'
  belongs_to :assignment, class_name: 'Assignment', foreign_key: 'reviewed_object_id'

  def questionnaire
    self.assignment.questionnaires.find_by_type('TeammateReviewQuestionnaire')
  end

  def contributor
    nil
  end

  def get_title
    "Teammate Review"
  end

  def self.teammate_response_report(id)
    # Example query
    # SELECT distinct reviewer_id FROM response_maps where type = 'TeammateReviewResponseMap' and reviewed_object_id = 711
    @reviewers = ResponseMap.select("DISTINCT reviewer_id").where(["reviewed_object_id = ? and type = ?", id, 'TeammateReviewResponseMap'])
  end
end
