class ApplicationController < ActionController::Base
  include AccessHelper

  # You want to get exceptions in development, but not in production.
  unless Rails.application.config.consider_all_requests_local
    rescue_from ActionView::MissingTemplate do |_exception|
      redirect_to root_path
    end
  end

  # forcing SSL only in the production mode
  force_ssl if Rails.env.production?

  helper_method :current_user, :current_user_role?
  protect_from_forgery with: :exception
  before_action :set_time_zone
  before_action :authorize

  def self.verify(_args); end

  def current_user_role?
    current_user.role.name
  end

  def current_role_name
    current_role.try :name
  end

  def current_role
    current_user.try :role
  end

  helper_method :current_user_role?

  def user_for_paper_trail
    session[:user].try :id if session[:user]
  end

  def undo_link(message)
    @version = Version.where('whodunnit = ?', session[:user].id).last
    if @version.try(:created_at) && Time.now - @version.created_at < 5.0
      @link_name = params[:redo] == "true" ? "redo" : "undo"
      message += "<a href = #{url_for(controller: :versions, action: :revert, id: @version.id, redo: !params[:redo])}>#{@link_name}</a>"
    end
  end

  def are_needed_authorizations_present?(id, *authorizations)
    @participant = Participant.find_by(id: id)
    return false if @participant.nil?
    authorization = Participant.get_authorization(@participant.can_submit, @participant.can_review, @participant.can_take_quiz)
    if authorizations.include? authorization
      return false
    else
      return true
    end
  end

  private

  def current_user
    @current_user ||= session[:user]
  end
  helper_method :current_user

  def current_user_role
    current_user.role
  end
  alias current_user_role? current_user_role

  def logged_in?
    current_user
  end

  def redirect_back(default = :root)
    redirect_to request.env['HTTP_REFERER'] ? :back : default
  end

  def set_time_zone
    Time.zone = current_user.timezonepref if current_user
  end

  def require_user
    invalid_login_status('in') unless current_user
  end

  def require_no_user
    invalid_login_status('out') if current_user
  end

  def invalid_login_status(status)
    flash[:notice] = "You must be logged #{status} to access this page!"
    redirect_back
  end

  def is_available(user, owner_id)
    user.id == owner_id ||
      user.admin? ||
      user.super_admin?
  end

  def record_not_found
    redirect_to controller: :tree_display, action: :list
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
    current_user.try(:id) == user_id
  end

  def denied(reason = nil)
    if reason
      redirect_to "/denied?reason=#{reason}"
    else
      redirect_to "/denied"
    end
  end
end
