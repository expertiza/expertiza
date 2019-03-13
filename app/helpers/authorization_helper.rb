module AuthorizationHelper

  # E1915 TODO populate with helper methods using session[:user] to make decisions
  # E1915 TODO each and every method defined here should be thoroughly tested in spec/helpers/authorization_helper_spec.rb
  # E1915 TODO search the code for "E1915 TODO" for some areas that need support from this module

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

  # Determine if the currently logged-in user is participating in an Assignment based on the passed in AssignmentTeam ID.
  # Although it would be better to take the Assignment ID as a parameter, the controller that this function gets used
  # in does not get passed an Assignment ID, only an AssignmentTeam ID
  def current_user_is_assignment_participant?(assignment_team_id)
    team = AssignmentTeam.find_by(id: assignment_team_id)
    if team && session[:user]
      participant = AssignmentParticipant.find_by(parent_id: team.assignment.id, user_id: current_user_id)
    end
    participant ? true : false
  end

  def current_user_teaching_staff_of_assignment?(assignment_id)
    assignment = Assignment.find(assignment_id)
    session[:user] &&
        (assignment.course_id && Course.find(assignment.course_id).instructor_id == session[:user].id ||
        assignment.instructor_id == session[:user].id ||
        TaMapping.exists?(ta_id: session[:user].id, course_id: assignment.course_id))
  end

  # Determine if the currently logged-in user IS of the given role name
  # If there is no currently logged-in user simply return false
  # TODO (Ginger): need to write tests
  def current_user_is_a?(role_name)
    session[:user] && session[:user].role ? session[:user].role.name == role_name : false
  end

  # Get the current user's ID
  # TODO (Ginger): need to write tests
  def current_user_id_as_string
    session[:user].id.to_s
  end

  # Determine if the currently logged-in user created the bookmark with the given ID
  # If there is no currently logged-in user (or that user has no ID) simply return false
  # Bookmark ID can be passed as string or number
  # If the bookmark is not found, simply return false
  def current_user_created_bookmark_id?(bookmark_id)
    return false unless current_user_id
    return false unless bookmark_id
    Bookmark.find(bookmark_id.to_i).user_id == current_user_id
  rescue ActiveRecord::RecordNotFound
    return false
  end

  # PRIVATE METHODS
  private

  # Determine if the currently logged-in user has the privileges of the given role name (or higher privileges)
  # Let the Role model define this logic for the sake of DRY
  # If there is no currently logged-in user simply return false
  def current_user_has_privileges_of?(role_name)
    session[:user] && session[:user].role ? session[:user].role.hasAllPrivilegesOf(Role.find_by(name: role_name)) : false
  end

  # Get the ID of the currently logged-in user
  # Return -1 if there is no currently logged-in user
  # Return -1 if the currently logged-in user has no id
  # This is done instead of returning nil to be very explicit and avoid matching to records which have nil user ID
  def current_user_id
    (session[:user] && session[:user].id) ? session[:user].id : -1
  end

end
