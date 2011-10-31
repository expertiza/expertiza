class TeamReviewResponseMap < ReviewResponseMap
  belongs_to :reviewee, :class_name => 'Team', :foreign_key => 'reviewee_id'
  belongs_to :contributor, :class_name => 'Team', :foreign_key => 'reviewee_id'

   def self.assign_reviewer contributor_id, reviewer_id, assignment_id
      if TeamReviewResponseMap.find(:first, :conditions => ['reviewee_id = ? and reviewer_id = ?', contributor_id, reviewer_id]).nil?
      TeamReviewResponseMap.create(:reviewee_id => contributor_id,
                                   :reviewer_id => reviewer_id,
                                   :reviewed_object_id => assignment_id)
    else
      raise "The reviewer, \""+reviewer.name+"\", is already assigned to this contributor."
    end
  end

end