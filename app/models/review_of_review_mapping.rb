class ReviewOfReviewMapping < ActiveRecord::Base
has_one :metareview, :class_name => "ReviewOfReview", :foreign_key => "mapping_id"
belongs_to :reviewer, :class_name => "AssignmentParticipant", :foreign_key => "reviewer_id"
belongs_to :reviewee, :class_name => "AssignmentParticipant", :foreign_key => "reviewee_id"
belongs_to :review_mapping, :class_name => "ReviewMapping", :foreign_key => "reviewed_object_id"


  def assignment
    self.review_mapping.assignment
  end

  def delete(force = nil)
    if self.metareview != nil and !force
      raise "A metareview exists for this mapping."
    elsif self.metareview != nil
      self.metareview.delete
    end
    self.destroy
  end  
  
  def self.import(row,session,id)
    if row.length < 3
       raise ArgumentError, "Not enough items. The string should contain: Author, Reviewer, ReviewOfReviewer1 <, ..., ReviewerOfReviewerN>" 
    end
    
    index = 2
    while index < row.length
      if assignment.team_assignment
        author = AssignmentTeam.find_by_name_and_parent_id(row[0].to_s.strip, assignment.id)
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
  
  # provide export functionality for Review Mappings
  def self.export(csv,parent_id)
    
    mappings = find(:all, :include => :review_mapping, :conditions => ['review_mappings.reviewed_object_id=?',parent_id])
    mappings = mappings.sort_by{|a| [a.review_mapping.reviewee.name,a.reviewee.name,a.reviewer.name]} 
    mappings.each{
          |map|          
          csv << [
            map.review_mapping.reviewee.name,
            map.reviewee.name,
            map.reviewer.name
          ]
      } 
  end
  
  def self.get_export_fields
    fields = ["contributor","reviewed by","metareviewed by"]
    return fields            
  end   
  
end
