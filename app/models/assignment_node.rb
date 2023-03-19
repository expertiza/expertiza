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

  def self.get(_sortvar = 'name', _sortorder = 'desc', user_id = nil, show = nil, _parent_id = nil, _search = nil)
    sortvar = 'created_at'
    if Assignment.column_names.include? sortvar
      includes(:assignment).where([get_assignment_query_conditions(show, user_id), get_assignments_managed_by_user(user_id)])
                       .order("assignments.#{sortvar} #{sortorder}")
    end
  end

   # get the query conditions for a public course
   def self.get_assignment_query_conditions(show = nil, user_id = nil)
    current_user = User.find_by(id: user_id)
    conditions = if show && current_user
                   if current_user.teaching_assistant? == false
                     "assignments.instructor_id = ?"
                   else
                     'assignments.course_id in (?)'
                   end
                 else
                   if current_user.teaching_assistant? == false
                     "(assignments.private = 0 or assignments.instructor_id = ?"
                   else
                     "(assignments.private = 0 or assignments.course_id in (?))"
                   end
                 end
    conditions += " and course_id = #{parent_id}" if parent_id
    conditions
  end

  # get the courses managed by the user
  def self.get_assignments_managed_by_user(user_id = nil)
    current_user = User.find(user_id)
    values = if current_user.teaching_assistant? == false
               user_id
             else
               Ta.get_mapped_courses(user_id)
             end
    values
  end


  # def self.get(sortvar = nil, sortorder = nil, user_id = nil, show = nil, parent_id = nil, _search = nil)
  #   if show
  #     conditions = if User.find(user_id).role.name != 'Teaching Assistant'
  #                    'assignments.instructor_id = ?'
  #                  else
  #                    'assignments.course_id in (?)'
  #                  end
  #   else
  #     if User.find(user_id).role.name != 'Teaching Assistant'
  #       conditions = '(assignments.private = 0 or assignments.instructor_id = ?)'
  #       values = user_id
  #     else
  #       conditions = '(assignments.private = 0 or assignments.course_id in (?))'
  #       values = Ta.get_mapped_courses(user_id)
  #     end
  #   end
  #   conditions += " and course_id = #{parent_id}" if parent_id
  #   sortvar ||= 'created_at'
  #   sortorder ||= 'desc'
  #   find_conditions = [conditions, values]
  #   includes(:assignment).where(find_conditions).order("assignments.#{sortvar} #{sortorder}")
  # end

  # Indicates that this object is always a leaf
  def is_leaf
    true
  end

  # Gets the name of the assignment
  # Return varchar datatype
  def get_name
    @assign_node ? @assign_node.name : Assignment.find_by(id: node_object_id).try(:name)
  end

  # Gets the directory of the assignment
  # Return varchar datatype
  def get_directory
    @assign_node ? @assign_node.directory_path : Assignment.find_by(id: node_object_id).try(:directory_path)
  end

  # Gets the creation date of the assignment
  # Return datetime datatype
  def get_creation_date
    @assign_node ? @assign_node.created_at : Assignment.find_by(id: node_object_id).try(:created_at)
  end

  # Gets the modified date of the assignment
  # Return datetime datatype
  def get_modified_date
    @assign_node ? @assign_node.updated_at : Assignment.find_by(id: node_object_id).try(:updated_at)
  end
  
  # Gets the course id to which the assignment belongs
  # Return int datatype
  def get_course_id
    @assign_node ? @assign_node.course_id : Assignment.find_by(id: node_object_id).try(:course_id)
  end

  # Checks if the assigment belongs to a particular course
  # Returns true or false
  def belongs_to_course?
    !get_course_id.nil?
  end

  # Gets the id of the instructor who created assignment
  # Return int datatype
  def get_instructor_id
    @assign_node ? @assign_node.instructor_id : Assignment.find_by(id: node_object_id).try(:instructor_id)
  end

  # Gets the id of the retrieved institution for the assignment
  # Return int datatype
  def retrieve_institution_id
    Assignment.find_by(id: node_object_id).try(:institution_id)
  end

  # Gets only private ?
  def get_private
    Assignment.find_by(id: node_object_id).try(:private)
  end

  # Gets the maximum number of participants allowed on the team.
  # Returns int data type
  def get_max_assignment_team_size
    Assignment.find_by(id: node_object_id).try(:max_team_size)
  end

  # Gets the topics assigned by 'intelligent algorithm' to the teams 
  # Returns tinyint datatype - 1 or 0 or assignments based on 0 or 1?
  def get_assignment_is_intelligent
    Assignment.find_by(id: node_object_id).try(:is_intelligent)
  end

  # Gets assignments depending on whether quiz is required or not
  # Returns tinyint datatype - 1 or 0 ?
  def get_assignment_require_quiz
    Assignment.find_by(id: node_object_id).try(:require_quiz)
  end
 
  # Gets if the assignment allows suggestions from participants or not
  def get_assignment_allow_suggestions
    Assignment.find_by(id: node_object_id).try(:allow_suggestions)
  end

  # Gets any TeamNodes associated with this object
  def get_teams
    TeamNode.get(node_object_id)
  end
end
