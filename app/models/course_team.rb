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
 
 def copy(assignment_id)
   new_team = AssignmentTeam.create_node_object(self.name, assignment_id)
   copy_members(new_team)
 end

  #depricate: the functionality belongs to course
  def add_participant(course_id, user)
    if CourseParticipant.find_by_parent_id_and_user_id(course_id, user.id) == nil
      CourseParticipant.create(:parent_id => course_id, :user_id => user.id, :permission_granted => user.master_permission_granted)
    end
  end

  #TODO: unused variable session
  def self.import(row,session,course_id,options)
    if (row.length < 2 and options[:has_column_names] == "true") or (row.length < 1 and options[:has_column_names] != "true")
      raise ArgumentError, "Not enough items"
    end

    if Course.find(course_id) == nil
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

  #should belong in course as export_teams method
  def self.export(csv, parent_id, options)
    course = Course.find(parent_id)
    assignmentList = Assignment.find_all_by_course_id(parent_id)

    assignmentList.each do |currentAssignment|
      AssignmentTeam.export(csv, currentAssignment.id, options)
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
