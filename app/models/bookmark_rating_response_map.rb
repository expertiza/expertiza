class BookmarkRatingResponseMap < ResponseMap
  belongs_to :reviewee, :class_name => 'Bookmark', :foreign_key => 'reviewee_id'
  belongs_to :assignment, :class_name => 'Assignment', :foreign_key => 'reviewed_object_id'

  def questionnaire
    self.assignment.questionnaires.find_by_type('BookmarkRatingResponseMap')
  end

  def contributor
    nil
  end

  def get_title
    return "Bookmark Review"
  end
end