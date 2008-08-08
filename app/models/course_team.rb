class CourseTeam < Team
  
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
