module CourseHelper
  #determin the courses that a user associate with
  def associated_courses(user)
    #NOTE: testing for roles in general is a bad practice but since the data base does not provide clear
    # way to get this association we have no other choice
    case user.role_id
      #admin and super admin should be able to see all courses
    when Role.superadministrator.id
      courses = Course.all
    when Role.administrator.id
      courses = Course.all

      #instructors should be able to see their own courses
    when Role.instructor.id
      courses = Course.where(instructor_id: user.id)

      #ta should be able to see all the course they are ta-ing
    when Role.ta.id
      ta_mappings = TaMapping.where(ta_id: user.id)
      course_id_list = Array.new
      ta_mappings.each do |ta_mapping|
        course_id_list << ta_mapping.course_id
      end
      course_id_list.uniq!
      courses = Array.new
      course_id_list.each do |course_id|
        courses << Course.find(course_id)
      end
      courses

      #student should be able to see the course that they participate in
      # to be safe we are not assuming that all assignment participants are in course participant
      # and all assignment team participants are in assignment participants
    when Role.student.id
      #find all course that the student participate in
      course_id_list = Array.new
      course_participant_list = CourseParticipant.where(user_id: user.id)
      course_participant_list.each do |course_participant|
        course_id_list << course_participant.course.id
      end
      #find all assignment the student participated in
      assignment_participant_list = AssignmentParticipant.where(user_id: user.id)
      assignment_participant_list.each do |assignment_participant|
        if !assignment_participant.assignment.course.nil?
          course_id_list << assignment_participant.assignment.course.id
        end
      end
      #find all teams the student participated in
      teams_users = TeamsUser.where(user_id: user.id)
      teams_users.each do |teams_user|
        team = Team.find(teams_user.team_id)
        if team.is_a?(AssignmentTeam)
          if !team.assignment.course.nil?
            course_id_list << team.assignment.course.id
          end
        elsif team.is_a?(CourseTeam)
          course_id_list << team.course.id
        end
      end
      course_id_list.uniq!
      courses = Array.new
      course_id_list.each do |course_id|
        courses << Course.find(course_id)
      end
      courses
    end
  end
end
