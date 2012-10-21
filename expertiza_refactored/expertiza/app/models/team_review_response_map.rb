class TeamReviewResponseMap < ReviewResponseMap
  belongs_to :reviewee, :class_name => 'Team', :foreign_key => 'reviewee_id'
  belongs_to :contributor, :class_name => 'Team', :foreign_key => 'reviewee_id'

end
