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
  before_action :filter_utf8
  before_action :set_locale

  def set_locale
    I18n.locale = user_locale
  end

  def user_locale
    # Checks whether the user is logged in, else the default locale is used
    if logged_in?
      # If the current user has set his preferred language, the locale is set according to their preference
      if !current_user.locale.nil?
        if current_user.locale != 'no_pref'
          return current_user.locale
          # If the user doesn't have any preference, the locale is taken from the course locale, if the current page is a course specific page or else default locale is used
        elsif current_user_role? && current_user_role.student? && respond_to?(:controller_locale)
          return controller_locale
        end
      else
        return I18n.default_locale
      end
    end
    I18n.default_locale
  end

  def locale_for_student
    # Gets participant using student from params
    participant_id = params[:id] || params[:student_id]
    if !participant_id.nil?
      participant = AssignmentParticipant.find_by(id: participant_id)
      # If id or student_id not correct, revert to locale based on courses.
      return locale_from_user_courses if participant.nil?

      # Find assignment from participant and find locale from the assignment
      assignment = participant.assignment
      return assignment.course.locale unless assignment.course.nil? || assignment.course.locale.nil?
    else
      return locale_from_user_courses
    end
    I18n.default_locale
  end

  def locale_from_user_courses
    # If the page is a course or assignment page with no specific student id, every course of that student is checked and if
    # the language for all these course are same, the page is displayed in that language
    course_participants = CourseParticipant.where(user_id: current_user.id)
    course_participants_locales = course_participants.map { |cp| cp.course.locale }
    # If no tasks, then possible to have no courses assigned.
    if course_participants_locales.uniq.length == 1 # && !@tasks.empty?
      course = course_participants.first.course
      return course.locale if course.locale?
    end
    I18n.default_locale
  end

  def filter_utf8
    remove_non_utf8(params)
  end

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
    version = Version.where('whodunnit = ?', session[:user].id).last
    return unless version.try(:created_at) && Time.now.in_time_zone - version.created_at < 5.0

    link_name = params[:redo] == 'true' ? 'redo' : 'undo'
    message + "<a href = #{url_for(controller: :versions, action: :revert, id: version.id, redo: !params[:redo])}>#{link_name}</a>"
  end

  def are_needed_authorizations_present?(id, *authorizations)
    participant = Participant.find_by(id: id)
    return false if participant.nil?

    authorization = participant.authorization
    !authorizations.include?(authorization)
  end

  private

  def current_user
    @current_user ||= session[:user]
  end

  helper_method :current_user

  def current_user_role
    current_user.role
  end

  # rubocop:disable Lint/DuplicateMethods
  alias current_user_role? current_user_role
  # rubocop:enable Lint/DuplicateMethods

  def logged_in?
    # Recommendation: rename to ever_logged_in? because that's how this actually works
    current_user
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
    redirect_back fallback_location: root_path
  end

  def available?(user, owner_id)
    user.id == owner_id ||
      user.admin? ||
      user.super_admin?
  end

  def record_not_found
    redirect_to controller: :tree_display, action: :list
  end

  def remove_non_utf8(hash)
    # remove non-utf8 chars from hash
    hash.each_pair do |_key, value|
      if value.is_a?(Hash)
        remove_non_utf8(value)
      elsif value.is_a?(String)
        encode_opts = {
          invalid: :replace,
          undef: :replace,
          replace: ''
        }
        value.encode!(Encoding.find('UTF-8'), encode_opts)
      end
    end
  end

  protected

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
      redirect_to '/denied'
    end
  end
end
