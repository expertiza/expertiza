module SimilarAssignmentsHelper
  include SimilarAssignmentsConstants
  # get all the assignemts in two different sets
  # one with all the assignments that are already marked as similar to the given assignment
  # another with all the remaining assignments that are not marked as similar yet
  def get_asssignments_set(selected)
    all_assignments = get_assignments_based_on_role
    assignment_array = []
    courses = get_courses_based_on_role
    all_assignments.each do |assignment|
      course_id = assignment.course_id
      if course_id.nil?
        next
      end
      if selected.include? assignment.id
        hash1 = {:title => assignment.name, :course_name => courses[course_id], :checked => true, :id => assignment.id}
        assignment_array.push(hash1)
      else
        hash2 = {:title => assignment.name, :course_name => courses[course_id], :checked => false, :id => assignment.id}
        assignment_array.push(hash2)
      end
    end
    assignment_array
  end

  # get all the assignments for the requested user
  # poupulate assignments list based on the role
  def get_assignments_based_on_role
    role = current_user.role.id
    page = params[:page]
    assignment_id = params[:id].to_i
    if page.nil?
      page = 0
    end
    offsets = page.to_i * popup_page_size
    case role
      when Role.ta.id
        course_ids = TaMapping.where(:ta_id => current_user.id).pluck(:course_id)
        @all_assignments = Assignment.where(:course_id => course_ids).where.not(:id => assignment_id).limit(popup_page_size).offset(offsets).order("created_at DESC")
      when Role.instructor.id
        course_ids = Course.where(:instructor_id => current_user.id).pluck(:id)
        @all_assignments = Assignment.where(:course_id => course_ids).where.not(:id => assignment_id).limit(popup_page_size).offset(offsets).order("created_at DESC")
      else
        @all_assignments = []
    end
    @all_assignments
  end

  # get all the courses for the requested user
  # poupulate courses list based on the role
  def get_courses_based_on_role
    role = current_user.role.id
    case role
      when Role.ta.id
        courses = TaMapping.where(:ta_id => current_user.id)
      when Role.instructor.id
        courses = Course.where(:instructor_id => current_user.id)
      when Role.administrator.id
        #todo
      when Role.superadministrator.id
        #todo
      else
        courses = []
    end
    courses_hash = {}
    courses.each {|course| courses_hash[course.id] = course.name}
    courses_hash
  end

  # fetch all the similar assignments for the given assignment
  def get_similar_assignment_ids(assignment_id)
    SimilarAssignment.where(:assignment_id => assignment_id).pluck(:is_similar_for)
  end
end
