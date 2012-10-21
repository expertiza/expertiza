
class SuperAdministrator < User
  
  QUESTIONNAIRE = [["My instructor's questionnaires",'list_instructors'],
            ["My admin's questionnaires",'list_admins'],
            ["My questionnaires",'list_mine'],
            ['All public questionnaires','list_all'],
            ['All private questionnaires','list_all_private']]
            
  SIGNUPSHEET = [["My instructor's signups",'list_instructors'],
            ["My admin's signups",'list_admins'],
            ['My signups','list_mine'],
            ['All public signups','list_all'],
            ['All private signups','list_all_private']]          
 
  ASSIGNMENT = [["My instructor's assignments",'list_instructors'],
                ["My admin's assignments",'list_admins'],
                ['My assignments','list_mine'],
                ['All public assignments','list_all'],
                ['All private assignments','list_all_private']]

  def get(object_type, id, user_id)
      object_type.find(:first, :conditions => ["id = ?", id])
  end

  def list_all(object_type, user_id)
    object_type.find(:all, :conditions => "private = 0")
  end
   
  def list_all_private(object_type, user_id)
    object_type.find(:all, :conditions => "private = 1")
  end
   
  def list_admins(object_type, user_id)
    if (object_type != SignupSheet)
      object_type.find(:all,
                       :joins => "inner join users on " + object_type.to_s.pluralize + ".instructor_id = users.id AND users.parent_id = " + user_id.to_s)
    else 
      object_type.find(:all,
                       :joins => "inner join users on instructor_id = users.id AND users.parent_id = " + user_id.to_s)  
    end                 
  end

  def list_instructors(object_type, user_id)
    if (object_type != SignupSheet)
      object_type.find(:all,
                       :joins => "inner join users on " + object_type.to_s.pluralize + ".instructor_id = users.id AND users.parent_id = " + user_id.to_s)
    else
      object_type.find(:all,
                       :joins => "inner join users on instructor_id = users.id AND users.parent_id = " + user_id.to_s)
    end                   
  end

  def get(object_type, id, user_id)
    object_type.find(:first, 
                     :conditions => ["id = ?", id])
  end
end