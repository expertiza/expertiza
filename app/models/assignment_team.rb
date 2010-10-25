class AssignmentTeam < Team
  belongs_to :assignment, :class_name => 'Assignment', :foreign_key => 'parent_id'
  has_many :review_mappings, :class_name => 'TeamReviewResponseMap', :foreign_key => 'reviewee_id'
 
  def get_hyperlinks
    links = Array.new
    for team_member in self.get_participants 
     if team_member.submitted_hyperlink != nil and team_member.submitted_hyperlink.strip.length > 0      
      links << team_member.submitted_hyperlink      
     end
    end
    return links
  end
  
  def get_codefiles
    codefiles = Codefile.new
    for team_member in self.get_participants 
      for codefile in team_member.get_codefiles
        codefiles << codefile
      end
      #codefiles << CodeReviewFile.getParticipantCodeFiles(team_member.id)    
    end
    return links
  end
  
  def get_path
    self.get_participants.first.get_path
  end
  
  def get_submitted_files
    self.get_participants.first.get_submitted_files
  end
  
  def get_review_map_type
    return 'TeamReviewResponseMap'
  end  
  
  def self.import(row,session,id,options)
    if (row.length < 2 and options[:has_column_names] == "true") or (row.length < 1 and options[:has_column_names] != "true")
       raise ArgumentError, "Not enough items" 
    end
        
    if Assignment.find(id) == nil
      raise ImportError, "The assignment with id \""+id.to_s+"\" was not found. <a href='/assignment/new'>Create</a> this assignment?"
    end
    
    if options[:has_column_names] == "true"
        name = row[0].to_s.strip
        index = 1
    else
        name = generate_team_name()
        index = 0
    end 
    
    currTeam = AssignmentTeam.find(:first, :conditions => ["name =? and parent_id =?",name,id])
    
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
       currTeam = AssignmentTeam.create(:name => name, :parent_id => id)
       parent = AssignmentNode.find_by_node_object_id(id)
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
    users = self.users        
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
      if !user.master_permission_granted.nil?
        p_permission_updated_at = user.permission_updated_at;
        p_digital_signature = user.digital_signature;
      end
     AssignmentParticipant.create(:parent_id => assignment_id, :user_id => user.id, :permission_granted => user.master_permission_granted, :permission_updated_at => p_permission_updated_at, :digital_signature => p_digital_signature)
   end    
  end
 
   
  def assignment
    Assignment.find(self.parent_id)
  end
 
  def get_reviews
    Review.get_assessments_for(self)
  end
  
  def self.get_team(participant)
    team = nil
    teams_users = TeamsUser.find_all_by_user_id(participant.user_id)
    teams_users.each {
      | tuser |
      fteam = Team.find(:first, :conditions => ['parent_id = ? and id = ?',participant.parent_id,tuser.team_id])
      if fteam
        team = fteam
      end      
    }
    team  
  end
end  

