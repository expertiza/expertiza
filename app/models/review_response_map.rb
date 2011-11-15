<<<<<<< HEAD
class ReviewResponseMap < ResponseMap
  belongs_to :assignment, :class_name => 'Assignment', :foreign_key => 'reviewed_object_id'
 
  def questionnaire
    self.assignment.questionnaires.find_by_type('ReviewQuestionnaire')
  end 
 
  def get_title
    return "Review"
  end
 
  def delete(force = nil)
    if self.response != nil and !force
      raise "A response exists for this mapping."
    elsif self.response != nil
      fmaps = FeedbackResponseMap.find_all_by_reviewed_object_id(self.response.id)
      fmaps.each{|fmap| fmap.delete(true)}      
      self.response.delete
    end    
    maps = MetareviewResponseMap.find_all_by_reviewed_object_id(self.id)
    maps.each{|map| map.delete(force)}     
    self.destroy
  end  

  def self.get_export_fields
    fields = ["contributor","reviewed by"]
    return fields            
  end   
  
  def self.export(csv,parent_id)
    mappings = find(:all, :conditions => ['reviewed_object_id=?',parent_id])
    mappings.sort!{|a,b| a.reviewee.name <=> b.reviewee.name} 
    mappings.each{
          |map|          
          csv << [
            map.reviewee.name,
            map.reviewer.name
          ]
      } 
  end  
  
  def self.import(row,session,id)    
    if row.length < 2
       raise ArgumentError, "Not enough items" 
    end
    
    assignment = Assignment.find(id)
    if assignment.nil?
      raise ImportError, "The assignment with id \"#{id}\" was not found. <a href='/assignment/new'>Create</a> this assignment?"
    end
    index = 1
    while index < row.length
      user = User.find_by_name(row[index].to_s.strip)      
      if user.nil?
        raise ImportError, "The user account for the reviewer \"#{row[index]}\" was not found. <a href='/users/new'>Create</a> this user?"
      end
      reviewer = AssignmentParticipant.find_by_user_id_and_parent_id(user.id,assignment.id)
      if reviewer == nil
        raise ImportError, "The reviewer \"#{row[index]}\" is not a participant in this assignment. <a href='/users/new'>Register</a> this user as a participant?"
      end           
      if assignment.team_assignment
         reviewee = AssignmentTeam.find_by_name_and_parent_id(row[0].to_s.strip, assignment.id)
         if reviewee == nil
           raise ImportError, "The author \"#{row[0].to_s.strip}\" was not found. <a href='/users/new'>Create</a> this user?"                   
         end
         existing = TeamReviewResponseMap.find_by_reviewee_id_and_reviewer_id(reviewee.id, reviewer.id) 
         if existing.nil?
           TeamReviewResponseMap.create(:reviewer_id => reviewer.id, :reviewee_id => reviewee.id, :reviewed_object_id => assignment.id)
         end
      else
         puser = User.find_by_name(row[0].to_s.strip)
         if user == nil
           raise ImportError, "The user account for the reviewee \"#{row[0]}\" was not found. <a href='/users/new'>Create</a> this user?"
         end
         reviewee = AssignmentParticipant.find_by_user_id_and_parent_id(puser.id, assignment.id)
         if reviewee == nil
           raise ImportError, "The author \"#{row[0].to_s.strip}\" was not found. <a href='/users/new'>Create</a> this user?"                   
         end  
         existing = ParticipantReviewResponseMap.find_by_reviewee_id_and_reviewer_id(reviewee.id, reviewer.id) 
         if existing.nil?
           ParticipantReviewResponseMap.create(:reviewer_id => reviewer.id, :reviewee_id => reviewee.id, :reviewed_object_id => assignment.id)
         end         
      end
      index += 1
    end 
  end  
  
  def show_feedback()    
    if self.response
      map = FeedbackResponseMap.find_by_reviewed_object_id(self.response.id)
      if map and map.response
        return "<br/><hr/><br/>"+map.response.display_as_html()
      end
    else
      return nil
    end
  end
=======
class ReviewResponseMap < ResponseMap
  belongs_to :assignment, :class_name => 'Assignment', :foreign_key => 'reviewed_object_id'
 
  def questionnaire
    self.assignment.questionnaires.find_by_type('ReviewQuestionnaire')
  end 
 
  def get_title
    return "Review"
  end
 
  def delete(force = nil)
    if self.response != nil and !force
      raise "A response exists for this mapping."
    elsif self.response != nil
      fmaps = FeedbackResponseMap.find_all_by_reviewed_object_id(self.response.id)
      fmaps.each{|fmap| fmap.delete(true)}      
      self.response.delete
    end    
    maps = MetareviewResponseMap.find_all_by_reviewed_object_id(self.id)
    maps.each{|map| map.delete(force)}     
    self.destroy
  end  

  def self.get_export_fields
    fields = ["contributor","reviewed by"]
    return fields            
  end   
  
  def self.export(csv,parent_id)
    mappings = find(:all, :conditions => ['reviewed_object_id=?',parent_id])
    mappings.sort!{|a,b| a.reviewee.name <=> b.reviewee.name} 
    mappings.each{
          |map|          
          csv << [
            map.reviewee.name,
            map.reviewer.name
          ]
      } 
  end  
  
  def self.import(row,session,id)    
    if row.length < 2
       raise ArgumentError, "Not enough items" 
    end
    
    assignment = Assignment.find(id)
    if assignment.nil?
      raise ImportError, "The assignment with id \"#{id}\" was not found. <a href='/assignment/new'>Create</a> this assignment?"
    end
    index = 1
    while index < row.length
      user = User.find_by_name(row[index].to_s.strip)      
      if user.nil?
        raise ImportError, "The user account for the reviewer \"#{row[index]}\" was not found. <a href='/users/new'>Create</a> this user?"
      end
      reviewer = AssignmentParticipant.find_by_user_id_and_parent_id(user.id,assignment.id)
      if reviewer == nil
        raise ImportError, "The reviewer \"#{row[index]}\" is not a participant in this assignment. <a href='/users/new'>Register</a> this user as a participant?"
      end           
      if assignment.team_assignment
         reviewee = AssignmentTeam.find_by_name_and_parent_id(row[0].to_s.strip, assignment.id)
         if reviewee == nil
           raise ImportError, "The author \"#{row[0].to_s.strip}\" was not found. <a href='/users/new'>Create</a> this user?"                   
         end
         existing = TeamReviewResponseMap.find_by_reviewee_id_and_reviewer_id(reviewee.id, reviewer.id) 
         if existing.nil?
           TeamReviewResponseMap.create(:reviewer_id => reviewer.id, :reviewee_id => reviewee.id, :reviewed_object_id => assignment.id)
         end
      else
         puser = User.find_by_name(row[0].to_s.strip)
         if user == nil
           raise ImportError, "The user account for the reviewee \"#{row[0]}\" was not found. <a href='/users/new'>Create</a> this user?"
         end
         reviewee = AssignmentParticipant.find_by_user_id_and_parent_id(puser.id, assignment.id)
         if reviewee == nil
           raise ImportError, "The author \"#{row[0].to_s.strip}\" was not found. <a href='/users/new'>Create</a> this user?"                   
         end  
         existing = ParticipantReviewResponseMap.find_by_reviewee_id_and_reviewer_id(reviewee.id, reviewer.id) 
         if existing.nil?
           ParticipantReviewResponseMap.create(:reviewer_id => reviewer.id, :reviewee_id => reviewee.id, :reviewed_object_id => assignment.id)
         end         
      end
      index += 1
    end 
  end  
  
  def show_feedback()    
    if self.response
      map = FeedbackResponseMap.find_by_reviewed_object_id(self.response.id)
      if map and map.response
        return "<br/><hr/><br/>"+map.response.display_as_html()
      end
    else
      return nil
    end
  end
>>>>>>> c4cd6ee2acd0c2721114a9165e8bf6050a7dd1ee
end