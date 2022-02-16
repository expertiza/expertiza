class Ta < User
  has_many :ta_mappings, dependent: :destroy

  QUESTIONNAIRE = [['My questionnaires', 'list_mine'],
                   ['All public questionnaires', 'list_all']].freeze

  ASSIGNMENT = [['My assignments', 'list_mine'],
                ['All public assignments', 'list_all']].freeze

  def courses_assisted_with
    courses = TaMapping.where(ta_id: id)
    courses.map { |c| Course.find(c.course_id) }
  end

  def list_all(object_type, user_id)
    object_type.where(['instructor_id = ? OR private = 0', user_id])
  end

  def list_mine(object_type, user_id)
    #### if we are loading "My Assignments" for a user who is a TA we need to find all assignments
    #### which are assigned to a course for which the user is a TA (in addition to his own assignments
    #### which he created
    if object_type.to_s.eql? 'Assignment'
      #### once the course_id on the assignments table is being assigned properly we can use
      #### this find method, until then use the one below.
      # Assignment.find_by_sql(["select assignments.id, assignments.name, assignments.directory_path " +
      #  "from assignments inner join ta_mappings ON (assignments.course_id=ta_mappings.course_id and ta_id=?) " +
      #  "UNION select assignments.id, assignments.name, assignments.directory_path from assignments where instructor_id=?",user_id,user_id])

      #### this find method compares the directories of an assignment and a course to find out if the
      #### the assignment is in a subdirectory of a course that the user is a TA for.
      Assignment.find_by_sql(['select assignments.id, assignments.name, assignments.directory_path ' \
      'from assignments, ta_mappings where assignments.course_id = ta_mappings.course_id and ta_mappings.ta_id=?', user_id])
    else
      object_type.where(['instructor_id = ?', user_id])
    end
  end

  def get(object_type, id, user_id)
    object_type.where(['id = ? AND (instructor_id = ? OR private = 0)', id, user_id]).first
  end

  # This method is potentially problematic: it assumes one TA only help teach one course.
  # This method only returns the instructor_id for the 1st course that this user help teach.  -Yang Oct. 05 2015
  def self.get_my_instructor(user_id)
    course_id = TaMapping.get_course_id(user_id)
    Course.find(course_id).instructor_id
  end

  # This method should be used to replace the "get_my_instructor" method
  def self.get_my_instructors(user_id)
    ta_mappings = TaMapping.where(ta_id: user_id)
    if ta_mappings.empty?
      []
    else
      instructor_ids = []
      ta_mappings.each do |ta_mapping|
        course_id = ta_mapping.course_id
        instructor_ids << Course.find(course_id).instructor_id
      end
      instructor_ids
    end
  end

  def self.get_mapped_instructor_ids(user_id)
    ids = []
    mappings = TaMapping.where(ta_id: user_id)
    mappings.each do |map|
      ids << map.course.instructor.id
    end
    ids
  end

  def self.get_mapped_courses(user_id)
    ids = []
    mappings = TaMapping.where(ta_id: user_id)
    mappings.each do |map|
      ids << map.course.id
    end
    ids
  end

  def get_instructor
    Ta.get_my_instructor(id)
  end

  def set_instructor(new_assign)
    new_assign.instructor_id = Ta.get_my_instructor(id)
    new_assign.course_id = TaMapping.get_course_id(id)
  end

  def assign_courses_to_assignment
    @courses = TaMapping.get_courses(id)
  end

  def teaching_assistant?
    true
  end

  def self.get_user_list(user)
    courses = Ta.get_mapped_courses(user.id)
    participants = []
    user_list = []
    courses.each do |course_id|
      course = Course.find(course_id)
      participants << course.get_participants
    end
    participants.each do |p_s|
      next if p_s.empty?

      p_s.each do |p|
        user_list << p.user if user.role.has_all_privileges_of?(p.user.role)
      end
    end
    user_list
  end
end
