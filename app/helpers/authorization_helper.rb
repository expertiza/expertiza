module AuthorizationHelper
  # Notes:
  # We use session directly instead of current_role_name and the like
  # Because helpers do not seem to have access to the methods defined in app/controllers/application_controller.rb

  # PUBLIC METHODS

  # Determine if the currently logged-in user has the privileges of a Super-Admin
  def current_user_has_super_admin_privileges?
    current_user_has_privileges_of?('Super-Administrator')
  end

  # Determine if the currently logged-in user has the privileges of an Admin (or higher)
  def current_user_has_admin_privileges?
    current_user_has_privileges_of?('Administrator')
  end

  # Determine if the currently logged-in user has the privileges of an Instructor (or higher)
  def current_user_has_instructor_privileges?
    current_user_has_privileges_of?('Instructor')
  end

  # Determine if the currently logged-in user has the privileges of a TA (or higher)
  def current_user_has_ta_privileges?
    current_user_has_privileges_of?('Teaching Assistant')
  end

  # Determine if the currently logged-in user has the privileges of a Student (or higher)
  def current_user_has_student_privileges?
    current_user_has_privileges_of?('Student')
  end

  # Determine if the currently logged-in user is participating in an Assignment based on the assignment_id argument
  def current_user_is_assignment_participant?(assignment_id)
    if user_logged_in?
      return AssignmentParticipant.exists?(parent_id: assignment_id, user_id: session[:user].id)
    end

    false
  end

  def current_user_teaching_staff_of_assignment?(assignment_id)
    assignment = Assignment.find(assignment_id)
    user_logged_in? &&
      (
          current_user_instructs_assignment?(assignment) ||
          current_user_has_ta_mapping_for_assignment?(assignment)
        )
  end

  # Determine if the currently logged-in user IS of the given role name
  # If there is no currently logged-in user simply return false
  # parameter role_name should be one of: 'Student', 'Teaching Assistant', 'Instructor', 'Administrator', 'Super-Administrator'
  def current_user_is_a?(role_name)
    current_user_and_role_exist? && session[:user].role.name == role_name
  end

  # Determine if the current user has the passed in id value
  # parameter id can be integer or string
  def current_user_has_id?(id)
    user_logged_in? && session[:user].id.eql?(id.to_i)
  end

  # Determine if the currently logged-in user created the bookmark with the given ID
  # If there is no currently logged-in user (or that user has no ID) simply return false
  # Bookmark ID can be passed as string or number
  # If the bookmark is not found, simply return false
  def current_user_created_bookmark_id?(bookmark_id)
    user_logged_in? && !bookmark_id.nil? && Bookmark.find(bookmark_id.to_i).user_id == session[:user].id
  rescue ActiveRecord::RecordNotFound
    false
  end

  # Determine if the given user can submit work
  def given_user_can_submit?(user_id)
    given_user_can?(user_id, 'submit')
  end

  # Determine if the given user can review work
  def given_user_can_review?(user_id)
    given_user_can?(user_id, 'review')
  end

  # Determine if the given user can take quizzes
  def given_user_can_take_quiz?(user_id)
    given_user_can?(user_id, 'take_quiz')
  end

  # Determine if the given user can read work
  def given_user_can_read?(user_id)
    # Note that the ability to read is in the model as can_take_quiz
    # Per Dr. Gehringer, "I believe that 'can_take_quiz' means that the participant is a reader,
    # but please check the code to verify".
    # This was verified in the Participant model
    given_user_can_take_quiz?(user_id)
  end

  def response_edit_allowed?(map, user_id)
    assignment = map.reviewer.assignment
    # if it is a review response map, all the members of reviewee team should be able to view the response (can be done from heat map)
    if map.is_a? ReviewResponseMap
      reviewee_team = AssignmentTeam.find(map.reviewee_id)
      return user_logged_in? &&
             (
               current_user_has_id?(user_id) ||
               reviewee_team.user?(session[:user]) ||
               current_user_has_admin_privileges? ||
               (current_user_is_a?('Instructor') && current_user_instructs_assignment?(assignment)) ||
               (current_user_is_a?('Teaching Assistant') && current_user_has_ta_mapping_for_assignment?(assignment))
             )
    end
    current_user_has_id?(user_id) ||
      (current_user_is_a?('Instructor') && current_user_instructs_assignment?(assignment)) ||
      (assignment.course && current_user_is_a?('Teaching Assistant') && current_user_has_ta_mapping_for_assignment?(assignment))
  end

  # Determine if there is a current user
  # The application controller method session[:user]
  # will return a user even if session[:user] has been explicitly cleared out
  # because it is "sticky" in that it uses "@session[:user] ||= session[:user]"
  # So, this method can be used to answer a controller's question
  # "is anyone CURRENTLY logged in"
  def user_logged_in?
    !session[:user].nil?
  end

  # Determine if the currently logged-in user is an ancestor of the passed in user
  def current_user_ancestor_of?(user)
    return session[:user].recursively_parent_of(user) if user_logged_in? && user

    false
  end

  # Recursively find an assignment for a given Response id. Because a ResponseMap
  # Determine if the current user is an instructor for the given assignment
  def current_user_instructs_assignment?(assignment)
    user_logged_in? && !assignment.nil? && (
      assignment.instructor_id == session[:user].id ||
      (assignment.course_id && Course.find(assignment.course_id).instructor_id == session[:user].id)
    )
  end

  # Determine if the current user and the given assignment are associated by a TA mapping
  def current_user_has_ta_mapping_for_assignment?(assignment)
    user_logged_in? && !assignment.nil? && TaMapping.exists?(ta_id: session[:user].id, course_id: assignment.course.id)
  end

  # Recursively find an assignment given the passed in Response id. Because a ResponseMap
  # can either point to an Assignment or another Response, recursively search until the
  # ResponseMap object's reviewed_object_id points to an Assignment.
  def find_assignment_from_response_id(response_id)
    response = Response.find(response_id.to_i)
    response_map = response.response_map
    response_map.assignment || find_assignment_from_response_id(response_map.reviewed_object_id)
  end

  # Finds the assignment_instructor for a given assignment. If the assignment is associated with
  # a course, the instructor for the course is returned. If not, the instructor associated
  # with the assignment is return.
  def find_assignment_instructor(assignment)
    if assignment.course
      Course.find_by(id: assignment.course.id).instructor
    else
      assignment.instructor
    end
  end

  # PRIVATE METHODS
  private

  # Determine if the currently logged-in user has the privileges of the given role name (or higher privileges)
  # Let the Role model define this logic for the sake of DRY
  # If there is no currently logged-in user simply return false
  def current_user_has_privileges_of?(role_name)
    current_user_and_role_exist? && session[:user].role.has_all_privileges_of?(Role.find_by(name: role_name))
  end

  # Determine if the given user is a participant of some kind
  # who is allowed to perform the given action ("submit", "review", "take_quiz")
  def given_user_can?(user_id, action)
    participant = Participant.find_by(id: user_id)
    return false if participant.nil?

    case action
    when 'submit'
      participant.can_submit
    when 'review'
      participant.can_review
    when 'take_quiz'
      participant.can_take_quiz
    else
      raise "Did not recognize user action '" + action + "'"
    end
  end

  def current_user_and_role_exist?
    user_logged_in? && !session[:user].role.nil?
  end
end
