class CourseTeam < Team
  
  def self.import(row,session,id,options)
    if row.length < 2
       raise ArgumentError, "Not enough items" 
    end
    
    course = Course.find(id)
    if course == nil
      raise ImportError, "The course with id \""+id.to_s+"\" was not found. <a href='/assignment/new'>Create</a> this assignment?"
    end
    
    if options[:has_column_names] == "true"
        name = row[0].to_s.strip
        index = 1
    else
        name = generate_team_name()
        index = 0
    end 
    
    currTeam = CourseTeam.find(:first, :conditions => ["name =? and parent_id =?",name,course.id])
    
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
       currTeam = CourseTeam.new
       currTeam.name = name
       currTeam.parent_id = course.id
       currTeam.save
       parent = CourseNode.find_by_node_object_id(course.id)
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
  
  def get_participant_type
    "CourseParticipant"
  end  
  
  def get_parent_model
    "Course"
  end
  
  def get_node_type
    "TeamNode"
  end
 
 def copy(assignment_id)
   new_team = AssignmentTeam.create_node_object(self.name, assignment_id)
   copy_members(new_team)
 end
 
 def add_participant(course_id, user)
   if CourseParticipant.find_by_parent_id_and_user_id(course_id, user.id) == nil
      if !user.master_permission_granted.nil?
        p_permission_updated_at = user.permission_updated_at;
        p_digital_signature = user.digital_signature;
      end
     CourseParticipant.create(:parent_id => course_id, :user_id => user.id, :permission_granted => user.master_permission_granted, :permission_updated_at => p_permission_updated_at, :digital_signature => p_digital_signature)
   end    
 end
end
