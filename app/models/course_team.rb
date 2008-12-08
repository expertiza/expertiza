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
       currTeam = Team.new
       currTeam.name = name
       currTeam.assignment_id = course.id
       currTeam.save
    end
      
    while(index < row.length) 
        user = User.find_by_name(row[index].to_s.strip)
        if user == nil
          raise ImportError, "The user \""+row[index].to_s.strip+"\" was not found. <a href='/users/new'>Create</a> this user?"                           
        elsif currTeam != nil         
          currUser = TeamsUser.find(:first, :conditions => ["team_id =? and user_id =?", currTeam.id,user.id])          
          if currUser == nil
            currUser = TeamsUser.new
            currUser.team_id = currTeam.id
            currUser.user_id = user.id
            currUser.save   
            
            CourseParticipant.create(:parent_id => course.id, :user_id => user.id, :permission_granted => true)
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
     CourseParticipant.create(:parent_id => course_id, :user_id => user.id, :permission_granted => user.master_permission_granted)
   end    
 end
end
