require 'goldberg_filters'
include GoldbergFilters

class ApplicationController < ActionController::Base
  before_filter :goldberg_security_filter

  protect_from_forgery unless Rails.env.test?
  around_filter :set_time_zone

  def set_time_zone
    old_time_zone = Time.zone
    logger.debug !(session[:user].nil?)
    if (!(session[:user].nil?)) 
      logger.debug "set timezone debug"
      current_user_id = session[:user].id
      preferredtimezone = User.find_by_id(current_user_id).timezonepref
      logger.debug preferredtimezone
      Time.zone = preferredtimezone if logged_in?
    end
  ensure
    yield
    Time.zone = preferredtimezone
  end

  def logged_in?
    current_user
  end

  def authorize(args = {})
    unless current_permission(args).allow?(params[:controller], params[:action])
      flash[:warn] = 'Please log in.'
      redirect_back
    end
    @user = current_user
  end

  def current_permission(args = {})
    @authority ||= Authority.new args.merge({
      current_user: current_user
    })
  end
  delegate :allow?, to: :current_permission
  helper_method :allow?

  def redirect_back(default = :root)
    redirect_to request.env['HTTP_REFERER'] ? :back : default
  end

  def current_user_role?
    current_user.role.name
  end
  helper_method :current_user_role?

  private

  def current_user
    @current_user ||= session[:user]
  end
  helper_method :current_user

  def require_user
    unless current_user
      store_location
      flash[:notice] = "You must be logged in to access this page"
      redirect_back
      return false
    end
  end

  def require_no_user
    if current_user
      store_location
      flash[:notice] = "You must be logged out to access this page"
      redirect_to session[:return_to]
      return false
    end
  end

  def store_location
    session[:return_to] = request.request_uri
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

  # Use this method to validate the current user in order to avoid allowing users
  # to see unauthorized data.
  # Ex: return unless current_user_id?(params[:user_id])
  def current_user_id?(user_id)
    if user_id != session[:user].id
      redirect_to '/denied'
      return false
    else
      return true
    end
  end

end
