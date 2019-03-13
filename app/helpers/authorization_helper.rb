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
      participant = AssignmentParticipant.find_by(parent_id: team.assignment.id, user_id: session[:user].id)
    end
    participant ? true : false
  end

  # PRIVATE METHODS
  private

  # Determine if the currently logged-in user has the privileges of the given role name (or higher privileges)
  # Let the Role model define this logic for the sake of DRY
  # If there is no currently logged-in user simply return false
  def current_user_has_privileges_of?(role_name)
    session[:user] && session[:user].role ? session[:user].role.hasAllPrivilegesOf(Role.find_by(name: role_name)) : false
  end

  # Determine if the currently logged-in user IS of the given role name
  # If there is no currently logged-in user simply return false
  def current_user_is_a?(role_name)
    session[:user] && session[:user].role ? session[:user].role.name == role_name : false
  end

end
