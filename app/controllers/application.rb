# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base
  
  def authorize 
    unless session[:user]
      flash[:notice] = "Please log in."
      redirect_to(:controller => 'auth', :action => 'login')
    end
  end
  
  protected
  def list(object_type)
    # Calls the correct listing method based on the role of the
    # logged-in user and the currently selected constraint.
    #
    # Example: object_type = Rubric, constraint = 'list_all'
    # is transformed into Instructor.list_all(object_type, session[:user].id)
    # if the user is currently logged in as an Instructor
    constraint = @display_option.name
    if constraint == nil or constraint == ''
      constraint = 'list_mine'
    end
    
    ApplicationHelper::get_user_role(session[:user]).send(constraint, object_type, session[:user].id)
  end

  def get(object_type, id)
    # Returns the first record found.  The record may not be found (e.g.,
    # because it is private and belongs to someone else), so catch the exceptions.
    ApplicationHelper::get_user_role(session[:user]).get(object_type, id, session[:user].id)
  end
  
  def set_up_display_options(object_type)
    # Create a set that will be used to populate the dropbox when a user lists a set of objects (assgts., questionnaires, etc.)
    # Get the Instructor::questionnaire constant
    @display_options = eval ApplicationHelper::get_user_role(session[:user]).class.to_s+"::"+object_type 
    @display_option = DisplayOption.new
    @display_option.name = 'list_mine'
    @display_option.name = params[:display_option][:name] if params[:display_option]
  end
end