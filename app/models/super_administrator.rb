
class SuperAdministrator < User
  
  QUESTIONNAIRE = [["My instructors' questionnaires",'list_instructors'],
            ["My admins' questionnaires",'list_admins'],
            ['My questionnaires','list_mine'],
            ['All public questionnaires','list_all'],
            ['All private questionnaires','list_all_private']]
 
  ASSIGNMENT = [["My instructors' assignments",'list_instructors'],
                ["My admins' assignments",'list_admins'],
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
    object_type.find(:all,
                     :joins => "inner join users on " + object_type.to_s.pluralize + ".instructor_id = users.id AND users.parent_id = " + user_id.to_s)
  end

  def list_instructors(object_type, user_id)
    object_type.find(:all,
                     :joins => "inner join users on " + object_type.to_s.pluralize + ".instructor_id = users.id AND users.parent_id = " + user_id.to_s)
  end

  def get(object_type, id, user_id)
    object_type.find(:first, 
                     :conditions => ["id = ?", id])
  end
end