class CourseTeam < Team
  belongs_to :course, class_name: 'Course', foreign_key: 'parent_id'

  # since this team is not an assignment team, the assignment_id is nil.
  def assignment_id
    nil
  end

  # Copy this course team to the assignment team
  def copy_to_assignment(assignment_id)
    assignment = Assignment.find_by(id: assignment_id)
    new_team = (assignment.auto_assign_mentor ? MentoredTeam : AssignmentTeam).create_team_and_node(assignment_id)

    new_team.update(name: name)
    copy_members(new_team)
  end

  # Overwrite Team.import() to Import a course_team from csv
  def self.import(row, course_id, options)
    raise ImportError, "The course with the id \"#{course_id}\" was not found. <a href='/courses/new'>Create</a> this course?" if Course.find(course_id).nil?

    @course_team = CourseTeam.new
    Team.import(row, course_id, options, @course_team)
  end

  # Overwrite Team.export() to Export a course_team to csv
  def self.export(csv, parent_id, options)
    @course_team = CourseTeam.new
    Team.export(csv, parent_id, options, @course_team)
  end

  # Export the fields of the csv column to be used in export_file_controller.rb
  def self.export_fields(options)
    fields = []
    fields.push('Team Name')
    fields.push('Team members') if options[:team_name] == 'false'
    fields.push('Course Name')
  end
end
