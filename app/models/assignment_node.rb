# Node type for Assignments

# Author: ajbudlon
# Date: 7/18/2008

class AssignmentNode < Node
  belongs_to :assignment, class_name: 'Assignment', foreign_key: 'node_object_id'
  belongs_to :node_object, class_name: 'Assignment', foreign_key: 'node_object_id'
  # Returns the table in which to locate Assignments
  def self.table
    'assignments'
  end

  # parametersi:
  #   sortvar: valid strings - name, created_at, updated_at, directory_path
  #   sortorder: valid strings - asc, desc
  #   user_id: instructor id for assignment
  #   parent_id: course_id if subset

  # returns: list of AssignmentNodes based on query
  def self.get(sortvar = nil, sortorder = nil, user_id = nil, show = nil, parent_id = nil, _search = nil)
    if show
      conditions = if User.find(user_id).role.name != 'Teaching Assistant'
                     'assignments.instructor_id = ?'
                   else
                     'assignments.course_id in (?)'
                   end
    else
      if User.find(user_id).role.name != 'Teaching Assistant'
        conditions = '(assignments.private = 0 or assignments.instructor_id = ?)'
        values = user_id
      else
        conditions = '(assignments.private = 0 or assignments.course_id in (?))'
        values = Ta.get_mapped_courses(user_id)
      end
    end
    conditions += " and course_id = #{parent_id}" if parent_id
    sortvar ||= 'created_at'
    sortorder ||= 'desc'
    find_conditions = [conditions, values]
    includes(:assignment).where(find_conditions).order("assignments.#{sortvar} #{sortorder}")
  end

  # Indicates that this object is always a leaf
  def is_leaf
    true
  end

  def get_name
    @assign_node ? @assign_node.name : Assignment.find_by(id: node_object_id).try(:name)
  end

  def get_directory
    @assign_node ? @assign_node.directory_path : Assignment.find_by(id: node_object_id).try(:directory_path)
  end

  def get_creation_date
    @assign_node ? @assign_node.created_at : Assignment.find_by(id: node_object_id).try(:created_at)
  end

  def get_modified_date
    @assign_node ? @assign_node.updated_at : Assignment.find_by(id: node_object_id).try(:updated_at)
  end

  def get_course_id
    @assign_node ? @assign_node.course_id : Assignment.find_by(id: node_object_id).try(:course_id)
  end

  def belongs_to_course?
    !get_course_id.nil?
  end

  def get_instructor_id
    @assign_node ? @assign_node.instructor_id : Assignment.find_by(id: node_object_id).try(:instructor_id)
  end

  def retrieve_institution_id
    Assignment.find_by(id: node_object_id).try(:institution_id)
  end

  def get_private
    Assignment.find_by(id: node_object_id).try(:private)
  end

  def get_max_team_size
    Assignment.find_by(id: node_object_id).try(:max_team_size)
  end

  def get_is_intelligent
    Assignment.find_by(id: node_object_id).try(:is_intelligent)
  end

  def get_require_quiz
    Assignment.find_by(id: node_object_id).try(:require_quiz)
  end

  def get_allow_suggestions
    Assignment.find_by(id: node_object_id).try(:allow_suggestions)
  end

  # Gets any TeamNodes associated with this object
  def get_teams
    TeamNode.get(node_object_id)
  end
end
