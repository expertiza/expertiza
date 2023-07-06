class CourseTeam < Team

  belongs_to :course, class_name: 'Course', foreign_key: 'parent_id'

  # NOTE: inconsistency in naming of users that's in the team
  #   currently they are being called: member, participant, user, etc...
  #   suggestion: refactor all to participant

  # Get parent course
  def parent_model
    'Course'
  end

  # Get the course
  def self.parent_model(id)
    Course.find(id)
  end

  # Prototype method to implement prototype pattern
  def self.prototype
    CourseTeam.new
  end

  # Copy this course team to the assignment team
  def copy_to_assignment_team(assignment_id)
    new_team = AssignmentTeam.create_team_and_node(assignment_id)
    new_team.name = name
    new_team.save
    copy_members(new_team)
  end

  # Adds a participant to the CourseTeam
  def add_participant(course_id, user)
    if CourseParticipant.find_by(parent_id: course_id, user_id: user.id).nil?
      CourseParticipant.create(parent_id: course_id, user_id: user.id, permission_granted: user.master_permission_granted)
    end
  end

  # Import from csv
  def self.import(row_hash, session, id, options)
    raise ArgumentError, "Record does not contain required items." if row_hash.length < self.required_import_fields.length
    raise ImportError, "The course with the id \"" + id.to_s + "\" was not found. <a href='/course/new'>Create</a> this course?" if Course.find(id).nil?
    Team.import_helper(row_hash, id, options, prototype)
  end

  def self.required_import_fields
    { "teammembers" => "Team Members" }
  end

  def self.optional_import_fields(id = nil)
    { "teamname" => "Team Name" }
  end

  def self.import_options
    { "handle_dups" => { "display" => "Handle Duplicates",
                         "options" => { "ignore" => "Ignore new team name",
                                        "replace" => "Replace the existing team with the new team",
                                        "insert" => "Insert any new team members into the existing team",
                                        "rename" => "Rename the new team and import" } } }
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
end