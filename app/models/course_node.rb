class CourseNode < Node
  belongs_to :course, :class_name => "Course", :foreign_key => "node_object_id"
  belongs_to :node_object, :class_name => "Course"

  # Returns the table in which to locate Courses
  def self.table
    "courses"
  end

  # parameters:
  #   sortvar: valid strings - name, created_at, updated_at, directory_path
  #   sortorder: valid strings - asc, desc
  #   user_id: instructor id for Course
  #   parent_id: not used for this type of object

  # returns: list of CourseNodes based on query
  # the get method will return all courses meeting the criteria, but the method name is necessary due to polymorphism
  def self.get(sortvar = 'name',sortorder ='ASC',user_id = nil,show = nil, parent_id = nil,search = nil)
    sortvar = 'created_at'
    sortorder = 'desc'
    if search
      splitsearch = search.split("+")
      if(splitsearch[0] == 'filter')
        search = splitsearch[1]
      else
        search = "%"+search+"%"
      end
      self.includes(:course).where([get_course_query_conditions(show, user_id)+ " and courses.name LIKE ?" , get_courses_managed_by_user(user_id), search]).order("courses.#{sortvar} #{sortorder}")
    else
      self.includes(:course).where([get_course_query_conditions(show, user_id) , get_courses_managed_by_user(user_id)]).order("courses.#{sortvar} #{sortorder}")
      end
  end

  #get the query conditions for a public course
  def self.get_course_query_conditions(show = nil, user_id = nil)
    this_user = User.find(user_id)

    if show
      if this_user.is_teaching_assistant? == false
        conditions = 'courses.instructor_id = ?'
      else
        conditions = 'courses.id in (?)'
      end
    else
      if this_user.is_teaching_assistant? == false
        conditions = '(courses.private = 0 or courses.instructor_id = ?)'
      else
        conditions = '(courses.private = 0 or courses.id in (?))'
      end
    end

    return conditions
  end

  #get the courses managed by the user
  def self.get_courses_managed_by_user(user_id = nil)
    this_user = User.find(user_id)

    if this_user.is_teaching_assistant? == false
      values = user_id
    else
      values = Ta.get_mapped_courses(user_id)
    end

    return values
  end

  # get parent id
  def self.get_parent_id
    folder = TreeFolder.find_by_name('Courses')
    parent = FolderNode.find_by_node_object_id(folder.id)
    if parent
      return parent.id
    else
      return nil
    end
  end

  # Gets any children associated with this object
  # the get_children method will return assignments belonging to a course, but the method name is necessary due to polymorphism
  def get_children(sortvar = nil,sortorder =nil,user_id = nil,show = nil, parent_id = nil,search =nil)
    AssignmentNode.get(sortvar,sortorder,user_id,show,self.node_object_id,search)
  end

  # Gets the name from the associated object
  def get_name
    Course.find(self.node_object_id).name
  end

  # Gets the directory_path from the associated object
  def get_directory
    Course.find(self.node_object_id).directory_path
  end

  # Gets the created_at from the associated object
  def get_creation_date
    Course.find(self.node_object_id).created_at
  end

  # Gets the updated_at from the associated object
  def get_modified_date
    Course.find(self.node_object_id).updated_at
  end

  # Gets any TeamNodes associated with this object
  def get_teams
    TeamNode.get(self.node_object_id)
  end

  def get_survey_distribution_id
    Course.find(self.node_object_id).survey_distribution_id
  end

end
