# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base
  helper_method :current_user_session, :current_user, :current_user_role?
  protect_from_forgery unless Rails.env.test?
  filter_parameter_logging :password, :password_confirmation, :clear_password, :clear_password_confirmation
  before_filter :set_time_zone

  def authorize
    unless current_user
      flash[:notice] = "Please log in."
      redirect_to :controller => 'user_sessions', :action => 'new'
    end
  end

  def current_user
    session[:user]
  end

  def current_user_id
    current_user.id
  end

  def current_user_role
    current_user.role
  end
  alias_method :current_user_role?, :current_user_role

  def logged_in?
    current_user
  end

  def set_time_zone
    Time.zone = current_user.timezonepref if current_user
  end

  def redirect_back(default = :root)
    redirect_to request.env['HTTP_REFERER'] ? :back : default
  end

  private

  def require_user
    invalid_login_status('in') unless current_user
  end

  def require_no_user
    invalid_login_status('out') if current_user
  end

  def invalid_login_status(status)
    flash[:notice] = "You must be logged #{status} to access this page"
    redirect_back
  end

  protected

  def set_up_display_options(object_type)
    # Create a set that will be used to populate the dropbox when a user lists a set of objects (assgts., questionnaires, etc.)
    # Get the Instructor::QUESTIONNAIRE constant
    @display_options ||= eval "#{current_user_role.class}::#{object_type}"
  end

  # Use this method to validate the current user in order to avoid allowing users
  # to see unauthorized data.
  # Ex: return unless current_user_id?(params[:user_id])
  def current_user_id?(user_id)
    redirect_to '/denied' unless current_user.try(:id) == user_id
  end
end
