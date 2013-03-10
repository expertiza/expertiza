class CourseTeam < Team
  belongs_to  :course, :class_name => 'Course', :foreign_key => 'parent_id'

#NOTE: inconsistency in naming of users that's in the team
#   currently they are being called: member, participant, user, etc...
#   suggestion: refactor all to participant

  #TODO: import_participants should belong to team class
  def import_participants(starting_index, row)
    index = starting_index
    while(index < row.length)
      user = User.find_by_name(row[index].to_s.strip)
      if user.nil?
        raise ImportError, "The user \""+row[index].to_s.strip+"\" was not found. <a href='/users/new'>Create</a> this user?"
      else
        if TeamsUser.find(:first, :conditions => ["team_id =? and user_id =?", id, user.id]).nil?
          add_member(user)
        end
      end
      index = index + 1
    end
  end


  def self.handle_duplicate(name, course_id, handle_dups)
    team = find(:first, :conditions => ["name =? and parent_id =?", name, course_id])

    #no duplicate
    if team.nil?
      return name
    end

    #ignore: not create the new team
    if handle_dups == "ignore"
      return nil
    end

    #rename: rename new team
    if handle_dups == "rename"
      return generate_team_name
    end

    #replace: delete old team
    if handle_dups == "replace"
      team.delete
      return name
    end

  end

  def self.import(row,session,course_id,options)
    if row.length < 2
       raise ArgumentError, "Not enough items" 
    end
    
    course = Course.find(course_id)
    if course == nil
      raise ImportError, "The course with id \""+course_id.to_s+"\" was not found. <a href='/assignment/new'>Create</a> this assignment?"
    end

    if options[:has_column_names] == "true"
        name = row[0].to_s.strip
        name = handle_duplicate(name, course_id, options[:handle_dups])
        index = 1
    else
        name = generate_team_name
        index = 0
    end

    if name.nil?
      return
    end

    team = CourseTeam.create(:name => name, :parent_id => course_id)
    course_node = CourseNode.find_by_node_object_id(id)
    TeamNode.create(:parent_id => course_node.id, :node_object_id => team.id)

    team.import_participants(index, row)
  end  
  
  def get_participant_type
    "CourseParticipant"
  end  
  
  def get_parent_model
    "Course"
  end
  
  def get_node_type
    "TeamNode"
  end
 
 def copy(assignment_id)
   new_team = AssignmentTeam.create_node_object(self.name, assignment_id)
   copy_members(new_team)
 end
 
 def add_participant(course_id, user)
   if CourseParticipant.find_by_parent_id_and_user_id(course_id, user.id) == nil
     CourseParticipant.create(:parent_id => course_id, :user_id => user.id, :permission_granted => user.master_permission_granted)
   end    
 end

  def self.export(csv, parent_id, options)
    course = Course.find(parent_id)
    assignmentList = Assignment.find_all_by_course_id(parent_id)
    assignmentList.each do |currentAssignment|
      currentAssignment.teams.each { |team|
        tcsv = Array.new
        teamUsers = Array.new
        tcsv.push(team.name)
        if (options["team_name"] == "true")
          teamMembers = TeamsUser.find(:all, :conditions => ['team_id = ?', team.id])
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

  def self.get_export_fields(options)
    fields = Array.new
    fields.push("Team Name")
    if (options["team_name"] == "true")
      fields.push("Team members")
    end
    fields.push("Assignment Name")
    fields.push("Course Name")
  end
end
