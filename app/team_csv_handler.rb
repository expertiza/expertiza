
class TeamCsvHandler
  def self.import(row, course_id, options)
    raise ImportError, "The course with the id \"#{course_id}\" was not found. <a href='/courses/new'>Create</a> this course?" unless Course.exists?(course_id)

    course_team = CourseTeam.prototype
    Team.import(row, course_id, options, course_team)
  end

  def self.export(csv, parent_id, options)
    course_team = CourseTeam.prototype
    Team.export(csv, parent_id, options, course_team)
  end

  def self.export_fields(options)
    fields = ['Team Name']
    fields.push('Team members') if options[:show_team_members] == 'true'
    fields.push('Course Name')
    fields
  end
end
