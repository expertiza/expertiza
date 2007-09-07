class ReviewOfReview < ActiveRecord::Base
    has_many :review_of_review_scores

  # Generate emails for reviewers when a new review of their work
  # is made
  #ajbudlon, sept 07, 2007        
  def email
   review_of_review_mapping = ReviewOfReviewMapping.find_by_id(self.review_of_review_mapping_id)
   review_mapping = ReviewMapping.find_by_id(review_of_review_mapping.review_mapping_id)
      
   if User.find_by_id(review_mapping.reviewer_id).email_on_review_of_review
     review_num = getReviewNumber(review_of_review_mapping)     
     review_id = review_of_review_mapping.review_id
     review = Review.find(review_id)
     
     
     Pgmailer.deliver_message(        
         User.find_by_id(review_mapping.reviewer_id),
         Assignment.find_by_id(review_mapping.assignment_id),
         "Review "+review_num.to_s,       
         "review of review",
         review.review_scores,
         self.review_of_review_scores)
   end  
  end
  
  # Get all review mappings for this assignment & reviewer
  # required to give reviewer location of new submission content
  # link can not be provided as it might give user ability to access data not
  # available to them.  
  #ajbudlon, sept 07, 2007       
  def getReviewNumber(mapping)
    reviewer_mappings = ReviewMapping.find_by_sql(
      "select * from review_of_review_mappings where assignment_id = " +self.id.to_s +
      " and review_id = " + mapping.review_id.to_s
    )
    review_num = 1
    for rm in reviewer_mappings
      if rm.reviewer_id != mapping.reviewer_id
        review_num += 1
      else
        break
      end
    end  
    return review_num
  end    
end
