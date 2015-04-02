#Node type for Assignments

#Author: ajbudlon
#Date: 7/18/2008

class AssignmentNode < Node
  belongs_to :assignment, :class_name => "Assignment", :foreign_key => "node_object_id"
  belongs_to :node_object, :class_name => 'Assignment'
  # Returns the table in which to locate Assignments
  def self.table
    "assignments"
  end

  # parametersi:
  #   sortvar: valid strings - name, created_at, updated_at, directory_path
  #   sortorder: valid strings - asc, desc
  #   user_id: instructor id for assignment
  #   parent_id: course_id if subset

  # returns: list of AssignmentNodes based on query
  def self.get(sortvar = nil, sortorder =nil, user_id = nil, show = nil, parent_id = nil, search=nil)
    if show
      if User.find(user_id).role.name != "Teaching Assistant"
        conditions = 'assignments.instructor_id = ?'
      else
        conditions = 'assignments.course_id in (?)'
      end
    else
      if User.find(user_id).role.name != "Teaching Assistant"
        conditions = '(assignments.private = 0 or assignments.instructor_id = ?)'
        values = user_id
      else
        conditions = '(assignments.private = 0 or assignments.course_id in (?))'
        values = Ta.get_mapped_courses(user_id)
      end
    end

    conditions += " and course_id = #{parent_id}"  if parent_id
      sortvar ||= 'created_at'
    sortorder ||= 'desc'

    if search
      conditions += " and assignments.name LIKE ?"
      search = "%#{search}%"
        find_conditions = [conditions, values, search]
    else
      find_conditions = [conditions, values]
    end
<<<<<<< HEAD
    self.includes(:assignment).where(find_conditions).order("assignments.#{sortvar} #{sortorder}")
=======
    find(:all, :include => :assignment, :conditions => find_conditions, :order => "assignments.#{sortvar} #{sortorder}")
>>>>>>> 2b0d82468950b1cbd827e0b97dd55b0c76bf29e7

  end

  # Indicates that this object is always a leaf
  def is_leaf
    true
  end

  # Gets the name from the associated object
  def get_name
<<<<<<< HEAD
  	unless @assign_node
    	@assign_node = Assignment.find(self.node_object_id)
    end
    @assign_node.name
=======
    Assignment.find(self.node_object_id).name
>>>>>>> 2b0d82468950b1cbd827e0b97dd55b0c76bf29e7
  end

  # Gets the directory_path from the associated object
  def get_directory
<<<<<<< HEAD
    #Assignment.find(self.node_object_id).directory_path
    unless @assign_node
    	@assign_node = Assignment.find(self.node_object_id)
    end
    @assign_node.directory_path
=======
    Assignment.find(self.node_object_id).directory_path
>>>>>>> 2b0d82468950b1cbd827e0b97dd55b0c76bf29e7
  end

  # Gets the created_at from the associated object
  def get_creation_date
<<<<<<< HEAD
    #Assignment.find(self.node_object_id).created_at
    unless @assign_node
    	@assign_node = Assignment.find(self.node_object_id)
    end
    @assign_node.created_at
=======
    Assignment.find(self.node_object_id).created_at
>>>>>>> 2b0d82468950b1cbd827e0b97dd55b0c76bf29e7
  end

  # Gets the updated_at from the associated object
  def get_modified_date
<<<<<<< HEAD
    #Assignment.find(self.node_object_id).updated_at
    unless @assign_node
   		@assign_node = Assignment.find(self.node_object_id)
    end
    @assign_node.updated_at
=======
    Assignment.find(self.node_object_id).updated_at
>>>>>>> 2b0d82468950b1cbd827e0b97dd55b0c76bf29e7
  end

  # Gets any TeamNodes associated with this object
  def get_teams
    TeamNode.get(self.node_object_id)
  end
end
