# Node type for Assignments

# Author: ajbudlon
# Date: 7/18/2008

class AssignmentNode < Node
  belongs_to :assignment, class_name: "Assignment", foreign_key: "node_object_id"
  belongs_to :node_object, class_name: 'Assignment', foreign_key: "node_object_id"
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
  def self.get(sortvar = nil, sortorder = nil, user_id = nil, show = nil, parent_id = nil, search = nil)
    if show
      conditions = if User.find(user_id).role.name != "Teaching Assistant"
                     'assignments.instructor_id = ?'
                   else
                     'assignments.course_id in (?)'
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
    conditions += " and course_id = #{parent_id}" if parent_id
    sortvar ||= 'created_at'
    sortorder ||= 'desc'
    find_conditions = [conditions, values]

    me = User.find(user_id)

    name = search[:name].to_s.strip
    participant_name = search[:participant_name].to_s.strip
    participant_fullname = search[:participant_fullname].to_s.strip
    due_since = search[:due_since].to_s.strip
    due_until = search[:due_until].to_s.strip
    created_since = search[:created_since].to_s.strip
    created_until = search[:created_until].to_s.strip

    associations = {assignment: [:due_dates]}

    associations[:assignment] << {participants: :user} if participant_name.present? || participant_fullname.present?

    query = self.includes(associations).where(find_conditions)

    query = query.where('name LIKE ?', "%#{name}%") if name.present?

    if due_since.present?
      due_since = due_since.to_time.utc.change(hour: 0, min: 0)
      query = query.where('due_dates.due_at >= ?', due_since)
    end

    if due_until.present?
      due_until = due_until.to_time.utc.change(hour: 23, min: 59)
      query = query.where('due_dates.due_at <= ?', due_until)
    end

    if created_since.present?
      created_since = created_since.to_time.utc.change(hour: 0, min: 0)
      query = query.where('created_at >= ?', created_since)
    end

    if created_until.present?
      created_until = created_until.to_time.utc.change(hour: 23, min: 59)
      query = query.where('created_at <= ?', created_until)
    end

    if participant_name.present?
      participant_names = User.where('name LIKE ?', "%#{participant_name}%")
                              .select {|user| me.can_impersonate? user}
                              .map(&:name)
      return [] if participant_names.empty?
      query = query.where(users: {name: participant_names})
    end

    if participant_fullname.present?
      participant_names = User.where('fullname LIKE ?', "%#{participant_fullname}%")
                              .select {|user| me.can_impersonate? user}
                              .map(&:name)
      return [] if participant_names.empty?
      query = query.where(users: {name: participant_names})
    end

    query.order("assignments.#{sortvar} #{sortorder}")
  end

  # Indicates that this object is always a leaf
  def is_leaf
    true
  end

  def get_name
    @assign_node ? @assign_node.name : Assignment.find_by(id: self.node_object_id).try(:name)
  end

  def get_directory
    @assign_node ? @assign_node.directory_path : Assignment.find_by(id: self.node_object_id).try(:directory_path)
  end

  def get_creation_date
    @assign_node ? @assign_node.created_at : Assignment.find_by(id: self.node_object_id).try(:created_at)
  end

  def get_modified_date
    @assign_node ? @assign_node.updated_at : Assignment.find_by(id: self.node_object_id).try(:updated_at)
  end

  def get_course_id
    @assign_node ? @assign_node.course_id : Assignment.find_by(id: self.node_object_id).try(:course_id)
  end

  def belongs_to_course?
    !get_course_id.nil?
  end

  def get_instructor_id
    @assign_node ? @assign_node.instructor_id : Assignment.find_by(id: self.node_object_id).try(:instructor_id)
  end

  def retrieve_institution_id
    Assignment.find_by(id: self.node_object_id).try(:institution_id)
  end

  def get_private
    Assignment.find_by(id: self.node_object_id).try(:private)
  end

  def get_max_team_size
    Assignment.find_by(id: self.node_object_id).try(:max_team_size)
  end

  def get_is_intelligent
    Assignment.find_by(id: self.node_object_id).try(:is_intelligent)
  end

  def get_require_quiz
    Assignment.find_by(id: self.node_object_id).try(:require_quiz)
  end

  def get_allow_suggestions
    Assignment.find_by(id: self.node_object_id).try(:allow_suggestions)
  end

  # Gets any TeamNodes associated with this object
  def get_teams
    TeamNode.get(self.node_object_id)
  end
end
