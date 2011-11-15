<<<<<<< HEAD
class MetareviewResponseMap < ResponseMap
  belongs_to :reviewee, :class_name => 'Participant', :foreign_key => 'reviewee_id'
  belongs_to :review_mapping, :class_name => 'ResponseMap', :foreign_key => 'reviewed_object_id'
  
  def show_review()
    if self.review_mapping.response
      return self.review_mapping.response.display_as_html()+"<br/><hr/><br/>"
    else
      return "<I>No review was performed.</I><br/><hr/><br/>"
    end
  end  
  
  def contributor
    self.review_mapping.reviewee
  end
  
  def questionnaire
    self.assignment.questionnaires.find_by_type('MetareviewQuestionnaire')
  end  
  
  def get_title
    return "Metareview"
  end  
  
  def assignment
    self.review_mapping.assignment
  end
  
  def self.export(csv,parent_id)    
    mappings = Assignment.find(parent_id).metareview_mappings    
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
  
  def self.import(row,session,id)
    if row.length < 3
       raise ArgumentError.new("Not enough items. The string should contain: Author, Reviewer, ReviewOfReviewer1 <, ..., ReviewerOfReviewerN>") 
    end
    
    index = 2
    while index < row.length
      if Assignment.find(id).team_assignment
        contributor = AssignmentTeam.find_by_name_and_parent_id(row[0].to_s.strip, id)        
      else
        user = User.find_by_name(row[0].to_s.strip)
        contributor = AssignmentParticipant.find_by_user_id_and_parent_id(user.id, id)
      end
      
      if contributor == nil
        raise ImportError, "Contributor, "+row[0].to_s+", was not found."     
      end      
      
      ruser = User.find_by_name(row[1].to_s.strip)
      reviewee = AssignmentParticipant.find_by_user_id_and_parent_id(ruser.id, id)
      if reviewee.nil?
        raise ImportError, "Reviewee,  "+row[1].to_s+", for contributor, "+contributor.name+", was not found."   
      end
      
      muser = User.find_by_name(row[index].to_s.strip)
      reviewer = AssignmentParticipant.find_by_user_id_and_parent_id(muser.id, id)
      if reviewer.nil?
        raise ImportError, "Metareviewer,  "+row[index].to_s+", for contributor, "+contributor.name+", and reviewee, "+row[1].to_s+", was not found."
      end
      
      if Assignment.find(id).team_assignment
        reviewmapping = TeamReviewResponseMap.find_by_reviewee_id_and_reviewer_id(contributor.id, reviewee.id)
      else
        reviewmapping = ParticipantReviewResponseMap.find_by_reviewee_id_and_reviewer_id(contributor.id, reviewee.id)
      end
      if reviewmapping.nil?
        raise ImportError, "No review mapping was found for contributor, "+contributor.name+", and reviewee, "+row[1].to_s+"."
      end
        
      existing_mappings = MetareviewResponseMap.find_all_by_reviewee_id_and_reviewer_id_and_reviewed_object_id(reviewee.id, reviewer.id, reviewmapping.id)
      # if no mappings have already been imported for this combination
      # create it. 

      if existing_mappings.size == 0
          MetareviewResponseMap.create(:reviewer_id => reviewer.id, :reviewee_id => reviewee.id, :reviewed_object_id => reviewmapping.id )                            
      end    
      
      index += 1
    end 
  end  
=======
class MetareviewResponseMap < ResponseMap
  belongs_to :reviewee, :class_name => 'Participant', :foreign_key => 'reviewee_id'
  belongs_to :review_mapping, :class_name => 'ResponseMap', :foreign_key => 'reviewed_object_id'
  
  def show_review()
    if self.review_mapping.response
      return self.review_mapping.response.display_as_html()+"<br/><hr/><br/>"
    else
      return "<I>No review was performed.</I><br/><hr/><br/>"
    end
  end  
  
  def contributor
    self.review_mapping.reviewee
  end
  
  def questionnaire
    self.assignment.questionnaires.find_by_type('MetareviewQuestionnaire')
  end  
  
  def get_title
    return "Metareview"
  end  
  
  def assignment
    self.review_mapping.assignment
  end
  
  def self.export(csv,parent_id)    
    mappings = Assignment.find(parent_id).metareview_mappings    
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
  
  def self.import(row,session,id)
    if row.length < 3
       raise ArgumentError.new("Not enough items. The string should contain: Author, Reviewer, ReviewOfReviewer1 <, ..., ReviewerOfReviewerN>") 
    end
    
    index = 2
    while index < row.length
      if Assignment.find(id).team_assignment
        contributor = AssignmentTeam.find_by_name_and_parent_id(row[0].to_s.strip, id)        
      else
        user = User.find_by_name(row[0].to_s.strip)
        contributor = AssignmentParticipant.find_by_user_id_and_parent_id(user.id, id)
      end
      
      if contributor == nil
        raise ImportError, "Contributor, "+row[0].to_s+", was not found."     
      end      
      
      ruser = User.find_by_name(row[1].to_s.strip)
      reviewee = AssignmentParticipant.find_by_user_id_and_parent_id(ruser.id, id)
      if reviewee.nil?
        raise ImportError, "Reviewee,  "+row[1].to_s+", for contributor, "+contributor.name+", was not found."   
      end
      
      muser = User.find_by_name(row[index].to_s.strip)
      reviewer = AssignmentParticipant.find_by_user_id_and_parent_id(muser.id, id)
      if reviewer.nil?
        raise ImportError, "Metareviewer,  "+row[index].to_s+", for contributor, "+contributor.name+", and reviewee, "+row[1].to_s+", was not found."
      end
      
      if Assignment.find(id).team_assignment
        reviewmapping = TeamReviewResponseMap.find_by_reviewee_id_and_reviewer_id(contributor.id, reviewee.id)
      else
        reviewmapping = ParticipantReviewResponseMap.find_by_reviewee_id_and_reviewer_id(contributor.id, reviewee.id)
      end
      if reviewmapping.nil?
        raise ImportError, "No review mapping was found for contributor, "+contributor.name+", and reviewee, "+row[1].to_s+"."
      end
        
      existing_mappings = MetareviewResponseMap.find_all_by_reviewee_id_and_reviewer_id_and_reviewed_object_id(reviewee.id, reviewer.id, reviewmapping.id)
      # if no mappings have already been imported for this combination
      # create it. 

      if existing_mappings.size == 0
          MetareviewResponseMap.create(:reviewer_id => reviewer.id, :reviewee_id => reviewee.id, :reviewed_object_id => reviewmapping.id )                            
      end    
      
      index += 1
    end 
  end  
>>>>>>> c4cd6ee2acd0c2721114a9165e8bf6050a7dd1ee
end