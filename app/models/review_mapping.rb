class ReviewMapping < ActiveRecord::Base
  belongs_to :assignment
  has_many :reviews
  
  def self.assign_reviewers(assignment_id, num_reviews, num_review_of_reviews)
    @authors = Participant.find(:all, :conditions => ['assignment_id = ? and submit_allowed=1', assignment_id])
    @reviewers = Participant.find(:all, :conditions => ['assignment_id = ? and review_allowed=1', assignment_id])
    puts 'authors.size = ', @authors.size
    puts 'reviewers.size = ', @reviewers.size
    
    stride = 1 # get_rel_prime(num_reviews, @reviewers.size)
    for i in 0 .. @reviewers.size - 1
      current_reviewer_candidate = i
      current_author_candidate = current_reviewer_candidate
      for j in 0 .. (@reviewers.size * num_reviews / @authors.size) - 1  # This method potentially assigns authors different #s of reviews, if limit is non-integer
        current_author_candidate = (current_author_candidate + stride) % @authors.size
        ReviewMapping.create(:author_id => @authors[current_author_candidate].user_id, :reviewer_id => @reviewers[i].user_id, :assignment_id => assignment_id)
      end
    end
    for i in 0 .. @reviewers.size - 1
      # The review mapping is such that ...
      #   0  reviews 1, 2, 3
      #   1  reviews 2, 3, 4
      #   etc.
      # The RoR mapping will be such that ...
      #   0  reviews 1's review of 2
      #   1  reviews 2's review of 3
      #   etc.
      #  To keep it simple, this code only creates 1 review of review; it ignores the 
      # of reviews of reviews specified on the Create Review Assignment page!
      current_reviewer_of_review_candidate = i
      current_reviewer_candidate = (i + 1) % @reviewers.size
      current_reviewee_candidate = (i + 2) % @reviewers.size
      review_map = ReviewMapping.find(:first, :conditions =>['assignment_id = ? and reviewer_id = ? and author_id = ?', assignment_id, @reviewers[i].user_id, @reviewers[current_reviewee_candidate].user_id])
      
      ReviewOfReviewMapping.create(:reviewer_id => 
                                   @reviewers[current_reviewer_of_review_candidate].user_id,
                                   :review_mapping_id => review_map.id,
                                   :assignment_id => assignment_id);
    end
  end
end