# == Schema Information
#
# Table name: users
#
#  id                        :integer          not null, primary key
#  name                      :string(255)      default(""), not null
#  crypted_password          :string(40)       default(""), not null
#  role_id                   :integer          default(0), not null
#  password_salt             :string(255)
#  fullname                  :string(255)
#  email                     :string(255)
#  parent_id                 :integer
#  private_by_default        :boolean          default(FALSE)
#  mru_directory_path        :string(128)
#  email_on_review           :boolean
#  email_on_submission       :boolean
#  email_on_review_of_review :boolean
#  is_new_user               :boolean          default(TRUE), not null
#  master_permission_granted :integer          default(0)
#  handle                    :string(255)
#  leaderboard_privacy       :boolean          default(FALSE)
#  digital_certificate       :text
#  persistence_token         :string(255)
#  timezonepref              :string(255)
#  public_key                :text
#  copy_of_emails            :boolean          default(FALSE)
#


class Ta < User
  has_many :ta_mappings
  has_and_belongs_to_many :courses, :join_table => :ta_mappings
  
  QUESTIONNAIRE = [['My questionnaires','list_mine'],
            ['All public questionnaires','list_all']]
  
  ASSIGNMENT = [['My assignments','list_mine'],
                ['All public assignments','list_all']]

  def courses_assisted_with
    courses.map { |c| Course.find(c.course_id) }
  end

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

  def is_teaching_assistant?
    return true
  end
  
end
