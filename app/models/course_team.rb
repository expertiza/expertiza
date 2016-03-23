class CourseTeam < Team
  belongs_to :course, :class_name => 'Course', :foreign_key => 'parent_id'

  #NOTE: inconsistency in naming of users that's in the team
  #   currently they are being called: member, participant, user, etc...
  #   suggestion: refactor all to participant

  # def participant_type
  #   "CourseParticipant"
  # end

  def get_parent_model
    "Course"
  end

  def get_node_type
    "TeamNode"
  end

  # since this team is not an assignment team, the assignment_id is nil.
  def assignment_id
    nil
  end

  def self.prototype
    CourseTeam.new
  end

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

  def self.import(row, course_id, options)
    raise ImportError, "The course with id \""+id.to_s+"\" was not found. <a href='/course/new'>Create</a> this course?" if Course.find(course_id) == nil
    @courseteam = prototype
    Team.import(row, course_id, options, @courseteam)
  end

  def self.export(csv, parent_id, options)
    @courseteam = prototype
    Team.export(csv, parent_id, options, @courseteam)
  end

  #REFACTOR END:: functionality of import, export, handle_duplicate shifted to team.rb


  def self.export_fields(options)
    fields = Array.new
    fields.push("Team Name")
    if options[:team_name] == "false"
      fields.push("Team members")
    end
    fields.push("Course Name")
  end


  def import_team_members(starting_index, row)
    index = starting_index
    while (index < row.length)
      user = User.find_by_name(row[index].to_s.strip)
      if user.nil?
        raise ImportError, "The user \""+row[index].to_s.strip+"\" was not found. <a href='/users/new'>Create</a> this user?"
      else
        if TeamsUser.where(["team_id =? and user_id =?", id, user.id]).first.nil?
          add_member(user, nil)
        end
      end
      index = index + 1
    end
  end

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
