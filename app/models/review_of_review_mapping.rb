class ReviewOfReviewMapping < ActiveRecord::Base
has_many :review_of_reviews

  def delete
    reviewofreviews = ReviewOfReview.find(:all, :conditions => ['review_of_review_mapping_id =?',self.id])
    if reviewofreviews.length > 0
      raise "At least one review of review has been performed."
    end
    self.destroy
  end
  
  def self.import(row,session)
    if row.length < 3
       raise ArgumentError, "Not enough items. The string should contain: Author, Reviewer, ReviewOfReviewer1 <, ..., ReviewerOfReviewerN>" 
    end
    
    assignment = Assignment.find(session[:assignment_id])
    index = 2
    while index < row.length
      if assignment.team_assignment
        author = Team.find_by_name(row[0].to_s.strip)
        query = "assignment_id = ? and reviewer_id = ? and team_id = ?"
      else
        author = User.find_by_name(row[0].to_s.strip)
        query = "assignment_id = ? and reviewer_id = ? and author_id = ?"
      end
      reviewer = User.find_by_name(row[1].to_s.strip)
      rofreviewer = User.find_by_name(row[index].to_s.strip)
      if rofreviewer != nil
        mapping = ReviewOfReviewMapping.new
        mapping.assignment_id = assignment.id
        mapping.review_reviewer_id = rofreviewer.id
        mapping.reviewer_id = reviewer.id
        mapping.review_mapping_id = ReviewMapping.find(:first, :conditions => [query, assignment.id, reviewer.id, author.id]).id
        review = Review.find_by_review_mapping_id(mapping.review_mapping_id)
        
        if review != nil
          mapping.review_id = review.id
          mapping.save
        end        
      end
      index += 1
    end 
  end
end
