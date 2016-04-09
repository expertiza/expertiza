class FeedbackResponseMap < ResponseMap
  belongs_to :reviewee, :class_name => 'Participant', :foreign_key => 'reviewee_id'
  belongs_to :review, :class_name => 'Response', :foreign_key => 'reviewed_object_id'
  belongs_to :reviewer, :class_name => 'AssignmentParticipant', dependent: :destroy

  def assignment
    self.review.map.assignment
  end

  def show_review()
    if self.review
      return self.review.display_as_html()
    else
      return "No review was performed"
    end
  end

  def get_title
    return "Feedback"
  end

  def questionnaire
    self.assignment.questionnaires.find_by_type('AuthorFeedbackQuestionnaire')
  end

  def contributor
    self.review.map.reviewee
  end
  def self.feedback_response_report(id,type)
    #Example query
    #SELECT distinct reviewer_id FROM response_maps where type = 'FeedbackResponseMap' and
    #reviewed_object_id in (select id from responses where
    #map_id in (select id from response_maps where reviewed_object_id = 722 and type = 'ReviewResponseMap'))
    @review_response_map_ids = ResponseMap.select("id").where(["reviewed_object_id = ? and type = ?", id, 'ReviewResponseMap'])
    @response_ids = Response.select("id").where(["map_id IN (?)", @review_response_map_ids])
    @reviewers = ResponseMap.select("DISTINCT reviewer_id").where(["reviewed_object_id IN (?) and type = ?", @response_ids, type])
  end
end

