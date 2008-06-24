class ReviewOfReview < ActiveRecord::Base
    has_many :review_of_review_scores

  def delete
    rOfRScores = ReviewOfReviewScore.find(:all, :conditions => ['review_of_review_id =?',self.id])
    rOfRScores.each {|review| rOfRScores.delete }
    self.destroy
  end

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
     
     user = User.find(review_mapping.reviewer_id)
     recipient = User.find_by_id(review_mapping.reviewer_id).email
     Mailer.deliver_message(
         {:recipients => recipient,
          :subject => "An new review of review is available for #{self.name}",
          :body => {
           :obj_name => Assignment.find_by_id(review_mapping.assignment_id).name,
           :type => "review of review",
           :location => "Review "+getReviewNumber(review_of_review_mapping).to_s,
           :review_scores => review.review_scores,
           :ror_review_scores => self.review_of_review_scores,
           :user_name => ApplicationHelper::get_user_first_name(user),
           :partial_name => "update"
          }
         }
        )         
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
