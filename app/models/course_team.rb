class CourseTeam < Team
  belongs_to :course, class_name: 'Course', foreign_key: 'parent_id'

  # Get parent course
  def parent_model
    'Course'
  end

  def self.parent_model(course_id)
    Course.find(course_id)
  end

  # Prototype method to implement prototype pattern
  def self.prototype
    CourseTeam.new
  end

  # Copy this course team to the assignment team
  def copy_to_assignment_team(assignment_id)
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

    # Delegates the import functionality to the TeamCsvHandler.
  def self.import_from_csv(row, course_id, options = {})
    TeamCsvHandler.import(row, course_id, options)
  end

  # Delegates the export functionality to the TeamCsvHandler.
  def self.export_to_csv(parent_id, options = {})
    TeamCsvHandler.export(parent_id, options)
  end

  # Defines the fields to be exported for the CSV, based on options provided.
  def self.export_fields(options = {})
    TeamCsvHandler.export_fields(options)
  end
	
# Adds a participant to the course.
  def add_participant(user_name)
    user = User.find_by(name: user_name)
    if user.nil?
      raise 'No user account exists with the name ' + user_name + ". Please <a href='" + url_for(controller: 'users', action: 'new') + "'>create one</a>."
    end
    begin
      participant = CourseParticipant.find_by(parent_id: id, user_id: user.id)
      if participant # If there is already a participant, raise an error. Otherwise, create it
        raise "The user #{user.name} is already a participant."
      else
				CourseParticipant.create(parent_id: id, user_id: user.id, permission_granted: user.master_permission_granted)
      end
    rescue ActiveRecord::RecordNotFound => e
      raise "Error adding participant: #{e.message}"
    rescue ActiveRecord::RecordInvalid => e
      raise "Error adding participant: #{e.message}"
    end
  end

  # Add member to the course team
  def add_member(user, _id = nil)
    raise "The user \"#{user.name}\" is already a member of the team, \"#{name}\"" if user?(user)

    t_user = TeamsUser.create(user_id: user.id, team_id: id)
    parent = TeamNode.find_by(node_object_id: id)
    TeamUserNode.create(parent_id: parent.id, node_object_id: t_user.id)
    add_participant(parent_id, user)
  end
end
