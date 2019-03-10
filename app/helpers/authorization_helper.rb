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

end
