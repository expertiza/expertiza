class ReviewMapping < ActiveRecord::Base
  def self.assign_reviewers(assignment_id, num_reviewers, num_review_of_reviewers)
    @reviewers = Participant.find(:all, :conditions => ['assignment_id = ? and review_allowed=1', assignment_id])
    
    stride = 1 # get_rel_prime(num_reviewers, @reviewers.size)
    for i in 1 .. @reviewers.size
      current_reviewer_candidate = i
      for j in 1 .. num_reviewers
        current_author_candidate = (current_author_candidate + stride) % @reviewers.size
        ReviewMapping.create(:author_id => current_author_candidate, :reviewer_id => i, :assignment_id => assignment_id)
      end
    end
  end
end
