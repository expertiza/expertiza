class ReviewOfReviewMapping < ActiveRecord::Base
has_many :review_of_reviews
belongs_to :reviewer, :class_name => "User", :foreign_key => "reviewer_id"
belongs_to :review_reviewer, :class_name => "User", :foreign_key => "review_reviewer_id"
belongs_to :review_mapping

  def delete
    reviewofreviews = ReviewOfReview.find(:all, :conditions => ['review_of_review_mapping_id =?',self.id])
    if reviewofreviews.length > 0
      raise "At least one review of review has been performed."
    end
    self.destroy
  end
  
  def self.import(row,session,id)
    if row.length < 3
       raise ArgumentError, "Not enough items. The string should contain: Author, Reviewer, ReviewOfReviewer1 <, ..., ReviewerOfReviewerN>" 
    end
    
    assignment = Assignment.find(id)
    index = 2
    while index < row.length
      if assignment.team_assignment
        author = Team.find_by_name(row[0].to_s.strip)
        query = "assignment_id = ? and reviewer_id = ? and team_id = ?"
      else
        author = User.find_by_name(row[0].to_s.strip)
        query = "assignment_id = ? and reviewer_id = ? and author_id = ?"
      end
      if author == nil
        raise ImportError, "Author, "+row[0].to_s+", was not found."     
      end      
      
      reviewer = User.find_by_name(row[1].to_s.strip)
      if reviewer == nil
        raise ImportError, "Reviewer,  "+row[1].to_s+", for author, "+author.name+", was not found."   
      end
      
      rofreviewer = User.find_by_name(row[index].to_s.strip)
      if rofreviewer == nil
        raise ImportError, "Review of Reviewer,  "+row[index].to_s+", for author, "+author.name+", and reviewer, "+row[1].to_s+", was not found."
      end
      
      reviewmapping = ReviewMapping.find(:first, :conditions => [query, assignment.id, reviewer.id, author.id])
      if reviewmapping == nil
        raise ImportError, "No review mapping was found for author, "+author.name+", and reviewer, "+row[1].to_s+"."
      end
      
      query = "select * from review_of_review_mappings where review_mapping_id in ("+reviewmapping.id.to_s+") and reviewer_id = "+reviewer.id.to_s+" and review_reviewer_id = "+rofreviewer.id.to_s
            
      existing_mappings = ReviewOfReviewMapping.find_by_sql(query)
      # if no mappings have already been imported for this combination
      # create it. 

      if existing_mappings.size == 0
          mapping = ReviewOfReviewMapping.new
          
          mapping.review_reviewer_id = rofreviewer.id
          mapping.reviewer_id = reviewer.id
          mapping.review_mapping_id = reviewmapping.id
                    
          mapping.save                       
      end    
      
      index += 1
    end 
  end
  
end
