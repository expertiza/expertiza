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
  end
end