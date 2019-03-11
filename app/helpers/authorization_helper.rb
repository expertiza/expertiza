module AuthorizationHelper

  # E1915 TODO populate with helper methods using session[:user] to make decisions
  # E1915 TODO each and every method defined here should be thoroughly tested in spec/helpers/authorization_helper_spec.rb
  # E1915 TODO search the code for "E1915 TODO" for some areas that need support from this module

  # Notes:
  # We use session directly instead of current_role_name and the like
  # Because helpers do not seem to have access to the methods defined in app/controllers/application_controller.rb

  # Determine if the currently logged-in user has the privileges of a TA
  # Let the Role model define this logic for the sake of DRY
  # If there is no currently logged-in user simply return false
  def current_user_has_ta_privileges?
    session[:user] ? session[:user].role.hasAllPrivilegesOf(Role.find_by(name: 'Teaching Assistant')) : false
  end

  # Determine if the currently logged-in user has any one of the defined roles in the Role model
  # These roles are: Student, Teaching Assistant, Instructor, Administrator, Super-Administrator
  # Student has the 'lowest' role, so we only check for that role. Any role that Student or 'higher' will pass the check
  # If there is no currently logged in user, return false
  def current_user_has_any_privileges?
    session[:user] ? session[:user].role.hasAllPrivilegesOf(Role.find_by(name: 'Student')) : false
  end

  # Determine if the currently logged-in user is participating in an Assignment based on the passed in AssignmentTeam ID.
  # Although it would be better to take the Assignment ID as a parameter, the controller that this function gets used
  # in does not get passed an Assignment ID, only an AssignmentTeam ID
  def current_user_is_assignment_participant?(assignment_team_id)
    team = AssignmentTeam.find_by(id: assignment_team_id)
    participant = AssignmentParticipant.find_by(parent_id: team.assignment.id, user_id: session[:user].id)
    participant ? true : false
  end

end
