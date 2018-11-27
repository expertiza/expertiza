module SimilarAssignmentsHelper
  def get_asssignments_set(selected)
    @all_assignments = get_assignments_based_on_role()

    @courses = get_courses_based_on_role()

    @all_assignments.each {
        |assignment|
      if (selected.include? assignment.id)
        hash1 = {:title => assignment.name, :course_name => @courses[assignment.course_id], :checked => true, :id => assignment.id}
        assignment_array.push(hash1)
      else
        hash2 = {:title => assignment.name, :course_name => @courses[assignment.course_id], :checked => false, :id => assignment.id}
        assignment_array.push(hash2)
      end}
    return assignment_array
  end

  def get_assignments_based_on_role()
    @role = current_user.role.name
    case @role
      when 'Teaching Assistant'
        course_ids = TaMapping.where(:ta_id => current_user.id).pluck(:course_id)
        @all_assignments = Assignment.where(:course_id => course_ids)
      when 'Instructor'
        @all_assignments = Assignment.where(:instructor_id => current_user.id)
      when 'Admin'
        #todo
      when 'Super Admin'
        #todo
      else
        @all_assignments = []
    end
    return @all_assignments
  end

  def get_courses_based_on_role()
    @role = current_user.role.name
    case @role
      when 'Teaching Assistant'
        courses = TaMapping.where(:ta_id => current_user.id)
      when 'Instructor'
        courses = Course.where(:instructor_id => current_user.id)
      when 'Admin'
        #todo
      when 'Super Admin'
        #todo
      else
        courses = []
    end
    coursesHash = Hash.new
    courses.each {|course| coursesHash[course.id] = course.name}
    return courseHash
  end
end
