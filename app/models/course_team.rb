class CourseTeam < Team
  belongs_to :course, class_name: 'Course', foreign_key: 'parent_id'

  # NOTE: inconsistency in naming of users that's in the team
  #   currently they are being called: member, participant, user, etc...
  #   suggestion: refactor all to participant

  # Get parent course
  def parent_model
    'Course'
  end

  def self.parent_model(id)
    Course.find(id)
  end

  # since this team is not an assignment team, the assignment_id is nil.
  def assignment_id
    nil
  end

  # Prototype method to implement prototype pattern
  def self.prototype
    CourseTeam.new
  end

  # Copy this course team to the assignment team
  def copy(assignment_id)
    assignment = Assignment.find_by(id: assignment_id)
    if assignment.auto_assign_mentor
      new_team = MentoredTeam.create_team_and_node(assignment_id)
    else
      new_team = AssignmentTeam.create_team_and_node(assignment_id)
    end
    new_team.name = name
    new_team.save
    copy_members(new_team)
  end

  # deprecated: the functionality belongs to course
  def add_participant(course_id, user)
    if CourseParticipant.find_by(parent_id: course_id, user_id: user.id).nil?
      CourseParticipant.create(parent_id: course_id, user_id: user.id, permission_granted: user.master_permission_granted)
    end
  end

  # Import from csv
  def self.import(row, course_id, options)
    raise ImportError, 'The course with the id "' + course_id.to_s + "\" was not found. <a href='/courses/new'>Create</a> this course?" if Course.find(course_id).nil?

    @course_team = prototype
    Team.import(row, course_id, options, @course_team)
  end

  # Export to csv
  def self.export(csv, parent_id, options)
    @course_team = prototype
    Team.export(csv, parent_id, options, @course_team)
  end

  # Export the fields of the csv column
  def self.export_fields(options)
    fields = []
    fields.push('Team Name')
    fields.push('Team members') if options[:team_name] == 'false'
    fields.push('Course Name')
  end

  # Add member to the course team
  def add_member(user, _id = nil)
    raise "The user \"#{user.username}\" is already a member of the team, \"#{name}\"" if user?(user)

    t_user = TeamsUser.create(user_id: user.id, team_id: id)
    parent = TeamNode.find_by(node_object_id: id)
    TeamUserNode.create(parent_id: parent.id, node_object_id: t_user.id)
    add_participant(parent_id, user)
  end
end
