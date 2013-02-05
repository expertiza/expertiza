
class Ta < User
  has_many :ta_mappings
  
  QUESTIONNAIRE = [['My questionnaires','list_mine'],
            ['All public questionnaires','list_all']]
  
  ASSIGNMENT = [['My assignments','list_mine'],
                ['All public assignments','list_all']]

  def list_all(object_type, user_id)
    object_type.find(:all, 
                     :conditions => ["instructor_id = ? OR private = 0", user_id])
  end
  
  def list_mine(object_type, user_id)
    
    #### if we are loading "My Assignments" for a user who is a TA we need to find all assignments
    #### which are assigned to a course for which the user is a TA (in addition to his own assignments
    #### which he created
    if(object_type.to_s.eql? "Assignment")
      #### once the course_id on the assignments table is being assigned properly we can use 
      #### this find method, until then use the one below.
      #Assignment.find_by_sql(["select assignments.id, assignments.name, assignments.directory_path " + 
      #  "from assignments inner join ta_mappings ON (assignments.course_id=ta_mappings.course_id and ta_id=?) " +
      #  "UNION select assignments.id, assignments.name, assignments.directory_path from assignments where instructor_id=?",user_id,user_id])
      
      #### this find method compares the directories of an assignment and a course to find out if the 
      #### the assignment is in a subdirectory of a course that the user is a TA for.
      Assignment.find_by_sql(["select assignments.id, assignments.name, assignments.directory_path " +
      "from assignments, ta_mappings where assignments.course_id = ta_mappings.course_id and ta_mappings.ta_id=?",user_id])    
    else
      object_type.find(:all, :conditions => ["instructor_id = ?", user_id])      
    end
  end
  
  def get(object_type, id, user_id)
    object_type.find(:first, 
                     :conditions => ["id = ? AND (instructor_id = ? OR private = 0)", 
                                     id, user_id])
  end
  
  def self.get_my_instructor(user_id)
    course_id = TaMapping.get_course_id(user_id)
    Course.find(course_id).instructor_id
  end
  
  def self.get_mapped_instructor_ids(user_id)
    ids = Array.new
    mappings = TaMapping.find_all_by_ta_id(user_id)
    mappings.each{
      |map|
      ids << map.course.instructor.id
    }
    return ids
  end  
  
  def self.get_mapped_courses(user_id)
    ids = Array.new
    mappings = TaMapping.find_all_by_ta_id(user_id)
    mappings.each{
      |map|
      ids << map.course.id
    }
    return ids
  end
  
  def get_instructor
    Ta.get_my_instructor(self.id)
  end
  
  def set_instructor (new_assign)
    new_assign.instructor_id = Ta.get_my_instructor(self.id)
    new_assign.course_id = TaMapping.get_course_id(self.id)
  end
  
  def set_courses_to_assignment
    @courses = TaMapping.get_courses(self.id)    
  end
  
end