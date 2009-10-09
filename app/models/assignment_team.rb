class AssignmentTeam < Team

  def self.import(row,session,id,options)
    if (row.length < 2 and options[:has_column_names] == "true") or (row.length < 1 and options[:has_column_names] != "true")
       raise ArgumentError, "Not enough items" 
    end
    
    assignment = Assignment.find(id)
    if assignment == nil
      raise ImportError, "The assignment with id \""+id.to_s+"\" was not found. <a href='/assignment/new'>Create</a> this assignment?"
    end
    
    if options[:has_column_names] == "true"
        name = row[0].to_s.strip
        index = 1
    else
        name = generate_team_name()
        index = 0
    end 
    
    currTeam = AssignmentTeam.find(:first, :conditions => ["name =? and parent_id =?",name,assignment.id])
    
    if options[:handle_dups] == "ignore" && currTeam != nil
      return
    end
    
    if currTeam != nil && options[:handle_dups] == "rename"
       name = generate_team_name()
       currTeam = nil
    end
    if options[:handle_dups] == "replace" && teams.first != nil        
       for teamsuser in TeamsUser.find(:all, :conditions => ["team_id =?", currTeam.id])
           teamsuser.destroy
       end    
       currTeam.destroy
       currTeam = nil
    end     
    
    if currTeam == nil
       currTeam = AssignmentTeam.new
       currTeam.name = name
       currTeam.parent_id = assignment.id
       currTeam.save   
       parent = AssignmentNode.find_by_node_object_id(assignment.id)
       TeamNode.create(:parent_id => parent.id, :node_object_id => currTeam.id)
    end
      
    while(index < row.length) 
        user = User.find_by_name(row[index].to_s.strip)
        if user == nil
          raise ImportError, "The user \""+row[index].to_s.strip+"\" was not found. <a href='/users/new'>Create</a> this user?"                           
        elsif currTeam != nil         
          currUser = TeamsUser.find(:first, :conditions => ["team_id =? and user_id =?", currTeam.id,user.id])          
          if currUser == nil
            currTeam.add_member(user)            
          end                      
        end
        index = index+1      
    end                
  end

  def email
    self.get_team_users.first.email    
  end

  def get_participant_type
    "AssignmentParticipant"
  end  
 
  def get_parent_model
    "Assignment"
  end
  
  def fullname
    self.name
  end
  
  def get_participants
    users = self.get_team_users
    participants = Array.new
    users.each{
      | user | 
      participant = AssignmentParticipant.find_by_user_id_and_parent_id(user.id,self.parent_id)
      if participant != nil
        participants << participant
      end
    }
    return participants    
  end

   
  def copy(course_id)
   new_team = CourseTeam.create({:name => self.name, :parent_id => course_id})    
   copy_members(new_team)
  end
 
  def add_participant(assignment_id, user)
   if AssignmentParticipant.find_by_parent_id_and_user_id(assignment_id, user.id) == nil
     AssignmentParticipant.create(:parent_id => assignment_id, :user_id => user.id, :permission_granted => user.master_permission_granted)
   end    
  end
 
   
  def assignment
    Assignment.find(self.parent_id)
  end
 
  def get_feedbacks
    review_mapping_query = "select id from review_mappings where assignment_id = "+self.assignment.id.to_s+" and reviewer_id in (select user_id from teams_users where team_id = "+self.id.to_s+")"   
    review_query = "select id from reviews where review_mapping_id in ("+review_mapping_query+")"
    
    feedbacks = ReviewFeedback.find_by_sql("select * from review_feedbacks where review_id in ("+review_query+")")
    return feedbacks.sort {|a,b| a.reviewer.name <=> b.reviewer.name}    
  end 
 
  #computes this participants current review scores:
  # avg_review_score
  # difference
  def compute_review_scores(questionnaire, questions)
    reviews = Review.find_by_sql("select * from reviews where review_mapping_id in (select id from review_mappings where team_id = #{self.id} and assignment_id = #{self.parent_id})")
    if reviews.length > 0 
      avg_review_score, max_score,min_score = AssignmentParticipant.compute_scores(reviews, questionnaire)
      return avg_review_score, max_score, min_score
    else
      return nil,nil,nil
    end
   end
end
