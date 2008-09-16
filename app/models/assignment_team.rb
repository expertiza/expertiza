class AssignmentTeam < Team

  def get_participant_type
    "AssignmentParticipant"
  end  
 
  def get_parent_model
    "Assignment"
  end
  
  def get_participants
    users = self.get_team_users
    participants = Array.new
    users.each{
      | user | 
      participants << AssignmentParticipant.find_by_user_id_and_parent_id(user.id,self.parent_id)
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
 
  #computes this participants current review scores:
  # avg_review_score
  # difference
  def compute_review_scores   
    reviews = Review.find_by_sql("select * from reviews where review_mapping_id in (select id from review_mappings where team_id = #{self.id} and assignment_id = #{self.parent_id})")
    if reviews.length > 0 
      avg_review_score, max_score, min_score = AssignmentParticipant.compute_scores(reviews)     
      max_assignment_score = Assignment.find(self.parent_id).get_max_review_score
      return avg_review_score/max_assignment_score,max_score/max_assignment_score,min_score/max_assignment_score
    else
      return nil,nil,nil
    end
   end
end
