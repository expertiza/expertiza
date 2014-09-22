class CourseTeam < Team
  belongs_to  :course, :class_name => 'Course', :foreign_key => 'parent_id'

  #NOTE: inconsistency in naming of users that's in the team
  #   currently they are being called: member, participant, user, etc...
  #   suggestion: refactor all to participant

  def get_participant_type
    "CourseParticipant"
  end

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

  def copy(assignment_id)
    new_team = AssignmentTeam.create_team_and_node(assignment_id)
    new_team.name = name
    new_team.save
    copy_members(new_team)
  end

  #deprecated: the functionality belongs to course
  def add_participant(course_id, user)
    if CourseParticipant.where(parent_id: course_id, user_id:  user.id).first == nil
      CourseParticipant.create(:parent_id => course_id, :user_id => user.id, :permission_granted => user.master_permission_granted)
    end
  end

  def export_participants
    userNames = Array.new
    participants = TeamsUser.where(['team_id = ?', self.id])
    participants.each do |participant|
      userNames.push(participant.name)
      userNames.push(" ")
    end
    return userNames
  end

  def export(team_name_only)
    output = Array.new
    output.push(self.name)
    if team_name_only == "false"
      output.push(self.export_participants)
    end
    course = Course.find(self.parent_id)
    output.push(course.name)
    return output
  end

  def self.handle_duplicate(team, name, course_id, handle_dups)
    if team.nil? #no duplicate
      return name
    end
    if handle_dups == "ignore" #ignore: do not create the new team
      p '>>>setting name to nil ...'
      return nil
    end
    if handle_dups == "rename" #rename: rename new team
      return self.generate_team_name(Course.find(course_id).name)
    end
    if handle_dups == "replace" #replace: delete old team
      team.delete
      return name
    else # handle_dups = "insert"
      return nil
    end
    end

    #TODO: unused variable session
    def self.import(row,session,course_id,options)
      if (row.length < 2 and options[:has_column_names] == "true") or (row.length < 1 and options[:has_column_names] != "true")
        raise ArgumentError, "Not enough fields on this line"
      end

      if Course.find(course_id) == nil
        raise ImportError, "The course with id \""+course_id.to_s+"\" was not found. <a href='/assignment/new'>Create</a> this course?"
      end

      if options[:has_column_names] == "true"
        name = row[0].to_s.strip
        team = where(["name =? and parent_id =?", name, course_id]).first
        team_exists = !team.nil?
        name = handle_duplicate(team, name, course_id, options[:handle_dups])
        index = 1
      else
        name = self.generate_team_name(Course.find(course_id).name)
        index = 0
      end

      # handle_dups == "rename" ||" replace"
      # create new team for the team to be inserted
      if name
        team=CourseTeam.create_team_and_node(course_id)
        team.name = name
        team.save
      end

      # handle_dups == "rename" ||" replace" || "insert"
      # insert team members into team unless team was pre-existing & we ignore duplicate teams
      if !(team_exists && options[:handle_dups] == "ignore")
        team.import_team_members(index, row)
      end
    end

    def self.export(csv, parent_id, options)
      course = Course.find(parent_id)
      if course.nil?
        raise ImportError, "The course with id \""+course_id.to_s+"\" was not found. <a href='/assignment/new'>Create</a> this course?"
      end

      teams = CourseTeam.where(parent_id: parent_id)
      teams.each do |team|
        csv << team.export(options[:team_name])
      end
    end

    def self.get_export_fields(options)
      fields = Array.new
      fields.push("Team Name")
      if (options[:team_name] == "false")
        fields.push("Team members")
      end
      fields.push("Course Name")
    end

    #deprecated: this is the original self.export function
    #      if this is a desired export behavior than
    #      it should either belong to course class or assignment team class
    def self.export_all_assignment_team_related_to_course(csv, parent_id, options)
      course = Course.find(parent_id)
      assignmentList = Assignment.where(course_id: parent_id)
      assignmentList.each do |currentAssignment|
        currentAssignment.teams.each { |team|
          tcsv = Array.new
          teamUsers = Array.new
          tcsv.push(team.name)
          if (options["team_name"] == "true")
            teamMembers = TeamsUser.where(['team_id = ?', team.id])
            teamMembers.each do |user|
              teamUsers.push(user.name)
              teamUsers.push(" ")
            end
            tcsv.push(teamUsers)
          end
          tcsv.push(currentAssignment.name)
          tcsv.push(course.name)
          csv << tcsv
        }
      end
    end

    def self.create_team_and_node(course_id)
      course = Course.find(course_id)
      teamname = Team.generate_team_name(course.name)
      team = CourseTeam.create(:name=>teamname, :parent_id => course_id)
      TeamNode.create(:parent_id =>course_id,:node_object_id=>team.id)
      team
    end
  end
