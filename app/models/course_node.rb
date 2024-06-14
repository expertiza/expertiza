class CourseNode < Node
  belongs_to :course, class_name: 'Course', foreign_key: 'node_object_id'
  belongs_to :node_object, class_name: 'Course', foreign_key: 'node_object_id'

  # Creates a new courese node from the given course
  def self.create_course_node(course)
    parent_id = CourseNode.get_parent_id
    @course_node = CourseNode.new
    @course_node.node_object_id = course.id
    @course_node.parent_id = parent_id if parent_id
    @course_node.save
  end

  # Returns the table in which to locate Courses
  def self.table
    'courses'
  end

  # parameters:
  #   sortvar: valid strings - name, created_at, updated_at, directory_path
  #   sortorder: valid strings - asc, desc
  #   user_id: instructor id for Course
  #   parent_id: not used for this type of object

  # returns: list of CourseNodes based on query
  # the get method will return all courses meeting the criteria, but the method name is necessary due to polymorphism
  def self.get(_sortvar = 'name', _sortorder = 'desc', user_id = nil, show = nil, _parent_id = nil, _search = nil)
    sortvar = 'created_at'
    if Course.column_names.include? sortvar
      includes(:course).where([get_course_query_conditions(show, user_id), get_courses_managed_by_user(user_id)])
                       .order("courses.#{sortvar} desc")
    end
  end

  # get the query conditions for a public course
  def self.get_course_query_conditions(show = nil, user_id = nil)
    current_user = User.find_by(id: user_id)
    conditions = if show && current_user
                   if current_user.teaching_assistant? == false
                     "courses.instructor_id = #{user_id}"
                   else
                     'courses.id in (?)'
                   end
                 else
                   if current_user.teaching_assistant? == false
                     "(courses.private = 0 or courses.instructor_id = #{user_id})"
                   else
                     "((courses.private = 0 and courses.instructor_id != #{user_id}) or courses.instructor_id = #{user_id})"
                   end
                 end
    conditions
  end

  # get the courses managed by the user
  def self.get_courses_managed_by_user(user_id = nil)
    current_user = User.find(user_id)
    values = if current_user.teaching_assistant? == false
               user_id
             else
               Ta.get_mapped_courses(user_id)
             end
    values
  end

  # get parent id
  def self.get_parent_id
    folder = TreeFolder.find_by(name: 'Courses')
    parent = FolderNode.find_by(node_object_id: folder.id)
    parent.id if parent
  end

  # Gets any children associated with this object
  # the get_children method will return assignments belonging to a course, but the method name is necessary due to polymorphism
  def get_children(sortvar = nil, sortorder = nil, user_id = nil, show = nil, _parent_id = nil, search = nil)
    AssignmentNode.get(sortvar, sortorder, user_id, show, node_object_id, search)
  end

  def get_name
    Course.find_by(id: node_object_id).try(:name)
  end

  def get_directory
    Course.find_by(id: node_object_id).try(:directory_path)
  end

  def get_creation_date
    Course.find_by(id: node_object_id).try(:created_at)
  end

  def get_modified_date
    Course.find_by(id: node_object_id).try(:updated_at)
  end

  def get_private
    Course.find_by(id: node_object_id).try(:private)
  end

  def get_instructor_id
    Course.find_by(id: node_object_id).try(:instructor_id)
  end

  def retrieve_institution_id
    Course.find_by(id: node_object_id).try(:institutions_id)
  end

  def get_teams
    TeamNode.get(node_object_id)
  end

  def get_survey_distribution_id
    Course.find_by(id: node_object_id).try(:survey_distribution_id)
  end
end
