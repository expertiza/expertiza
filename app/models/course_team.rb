class CourseTeam < Team
  belongs_to :course, :class_name => 'Course', :foreign_key => 'parent_id'

  #NOTE: inconsistency in naming of users that's in the team
  #   currently they are being called: member, participant, user, etc...
  #   suggestion: refactor all to participant

  #Get parent course
  def get_parent_model
    "Course"
  end

  #Get team node type
  def get_node_type
    "TeamNode"
  end

  # since this team is not an assignment team, the assignment_id is nil.
  def assignment_id
    nil
  end

  #Prototype method to implement prototype pattern
  def self.prototype
    CourseTeam.new
  end

  #Copy this course team to the assignment team
  def copy(assignment_id)
    new_team = AssignmentTeam.create_team_and_node(assignment_id, false)
    new_team.name = name
    new_team.save
    copy_members(new_team)
  end

  #deprecated: the functionality belongs to course
  def add_participant(course_id, user)
    if CourseParticipant.where(parent_id: course_id, user_id: user.id).first == nil
      CourseParticipant.create(:parent_id => course_id, :user_id => user.id, :permission_granted => user.master_permission_granted)
    end
  end

  #REFACTOR BEGIN:: functionality of import, export, handle_duplicate shifted to team.rb

  #Import from csv
  def self.import(row, course_id, options)
    raise ImportError, "The course with id \""+id.to_s+"\" was not found. <a href='/course/new'>Create</a> this course?" if Course.find(course_id) == nil
    @course_team = prototype
    Team.import(row, course_id, options, @course_team)
  end

  #Export to csv
  def self.export(csv, parent_id, options)
    @course_team = prototype
    Team.export(csv, parent_id, options, @course_team)
  end

  #REFACTOR END:: functionality of import, export, handle_duplicate shifted to team.rb

  #Export the fields of the csv column
  def self.export_fields(options)
    fields = Array.new
    fields.push("Team Name")
    if options[:team_name] == "false"
      fields.push("Team members")
    end
    fields.push("Course Name")
  end

  #Add member to the course team
  def add_member(user, assignment_id)
    if has_user(user)
      raise "\""+user.name+"\" is already a member of the team, \""+self.name+"\""
    end

    t_user = TeamsUser.create(:user_id => user.id, :team_id => self.id)
    parent = TeamNode.find_by_node_object_id(self.id)
    TeamUserNode.create(:parent_id => parent.id, :node_object_id => t_user.id)
    add_participant(self.parent_id, user)
  end
end
