# Administrator Class
# Subtype of User class
# Author: unknown
class Administrator < User
  
  QUESTIONNAIRE = [["My instructors' questionnaires",'list_instructors'],
            ['My questionnaires','list_mine'],
            ['All public questionnaires','list_all']]
            
  SIGNUPSHEET = [["My instructors' signups",'list_instructors'],
            ['My signups','list_mine'],
            ['All public signups','list_all']]          
            
  ASSIGNMENT = [["My instructors' assignments",'list_instructors'],
                ['My assignments','list_mine'],
                ['All public assignments','list_all']]
    
  def list_instructors(object_type, user_id)
    object_type.find(:all,
                     :joins => "inner join users on " + object_type.to_s.pluralize + ".instructor_id = users.id AND users.parent_id = " + user_id.to_s)
  end
  
  def list_all(object_type, user_id)
    object_type.find(:all, 
                     :conditions => ["instructor_id = ? OR private = 0", user_id])
  end
  
  # This method gets a questionnaire or an assignment, making sure that current user is allowed to see it.
  def get(object_type, id, user_id)
    object_type.find(:first, 
                     :conditions => ["id = ? AND (instructor_id = ? OR private = 0)", 
                                     id, user_id]) # You are allowed to get it if it is public, or if your id is the one that created it.
  end
end