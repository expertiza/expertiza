class AuthController < ApplicationController
  helper :auth
  before_filter :authorize, :except => :login

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :login, :logout ],
         :redirect_to => { :action => :list }

  def login
    if request.get?
      AuthController.clear_session(session)
    else
      user = User.find_by_login(params[:login][:name])

      if user and user.valid_password?(params[:login][:password])
        logger.info "User #{params[:login][:name]} successfully logged in"
        session[:user] = user
        AuthController.set_current_role(user.role_id,session)

      my_object = {:user_id => user.id, :user_name=>user.name,:status => 1 }
      cookies[:login_suc] = {
          :value => ActiveSupport::YamlMessageVerifier.new('test').generate(my_object),
          :expires => 4.years.from_now
      }

        respond_to do |wants|
          wants.html do
            ## This line must be modified to read as shown at left when a new version of Goldberg is installed!
            redirect_to :controller => AuthHelper::get_home_controller(session[:user]), :action => AuthHelper::get_home_action(session[:user])
          end
          wants.xml do
            render :nothing => true, :status => 200
          end
        end

      else
        logger.warn "Failed login attempt"
        respond_to do |wants|
          wants.html do
            flash[:error] = "Incorrect Name/Password"
            redirect_to :controller => 'password_retrieval', :action => 'forgotten'
          end
          wants.xml do
            render :nothing => true, :status => 404
          end
        end
      end
    end
  end  # def login

  def login_failed
    flash.now[:error] = "Incorrect Name/Password"
    render :action => 'forgotten'
  end

  def logout
      my_object = { :status => 0}
      cookies[:login_suc] = {
          :value => ActiveSupport::YamlMessageVerifier.new('test').generate(my_object),
          :expires => 4.years.from_now
      }
    AuthController.logout(session)
    redirect_to '/'
  end

  def self.authorised?(session, params)
    authorised = false  # default
    check_controller = false

    if params[:controller] == 'content_pages' and
        params[:action] == 'view'
      if session[:credentials].pages.has_key?(params[:page_name].to_s)
        if session[:credentials].pages[params[:page_name].to_s] == true
          logger.info "Page: authorised"
          authorised = true
        else
          logger.info "Page: NOT authorised"
        end
      else
        logger.warn "(Unknown page? #{params[:page_name].to_s})"
      end
    else
      # Check if there's a specific permission for an action
      if session[:credentials].actions.has_key?(params[:controller])
        if session[:credentials].actions[params[:controller]].has_key?(params[:action])
          if session[:credentials].actions[params[:controller]][params[:action]]
            logger.info "Action: authorised"
            authorised = true
          else
            logger.info "Action: NOT authorised"
          end
        else
          check_controller = true
        end
      else
        check_controller = true
      end

      # Check if there's a general permission for a controller
      if check_controller
        if session[:credentials].controllers.has_key?(params[:controller])
          if session[:credentials].controllers[params[:controller]]
            logger.info "Controller: authorised"
            authorised = true
          else
            logger.info "Controller: NOT authorised"
          end
        else
          end
      end
    end  # Check permissions

    logger.info "Authorised? #{authorised.to_s}"
    return authorised
  end


  protected

  def self.logout(session)
    self.clear_session(session)
  end

  def self.set_current_role(role_id, session)
    if role_id
       role = Role.find(role_id)
       if role
          if not role.cache or not role.cache.has_key?(:credentials)
             Role.rebuild_cache
          end
          session[:credentials] = role.cache[:credentials]
          session[:menu] = role.cache[:menu]
          logger.info "Logging in user as role #{session[:credentials].class}"
       else
          logger.error "Something went seriously wrong with the role"
       end
    end
  end

  def self.clear_session(session)
    session[:user_id] = nil
    session[:user] = nil
    session[:credentials] = nil
    session[:menu] = nil
    session[:clear] = true
    session[:assignment_id] = nil
  end

#clears any identifying info from session
  def self.clear_user_info(session, assignment_id)
    session[:user_id] = nil
    session[:user] = ""  #sets user to an empty string instead of nil, to show that the user was logged in
    role = Role.find(1)
      if role
        if not role.cache or not role.cache.has_key?(:credentials)
          Role.rebuild_cache
        end
          session[:credentials] = role.cache[:credentials]
          session[:menu] = role.cache[:menu]
      end
    session[:clear] = true
    session[:assignment_id] = assignment_id
  end

end


# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base

  helper_method :current_user_session, :current_user
  protect_from_forgery unless Rails.env.test?
  filter_parameter_logging :password, :password_confirmation, :clear_password, :clear_password_confirmation

  def authorize
    unless session[:user]
      flash[:notice] = "Please log in."
      redirect_to(:controller => 'user_sessions', :action => 'new')
    end
  end

  private
  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.record
  end

  def require_user
    unless current_user
      store_location
      flash[:notice] = "You must be logged in to access this page"
      redirect_to session[:return_to]
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

module ActiveSupport
  class YamlMessageVerifier < MessageVerifier
    def verify(signed_message)
      raise InvalidSignature if signed_message.blank?

      data, digest = signed_message.split("--")
      if data.present? && digest.present? && secure_compare(digest, generate_digest(data))
        str = ActiveSupport::Base64.decode64(data)
        if str[0..2] == '---'
          YAML::load str
        else # Handle old Marshal.dump'd session
          Marshal.load(str)
        end
      else
        raise InvalidSignature
      end
    end

    def generate(value)
      data = ActiveSupport::Base64.encode64s(YAML::dump value)
      "#{data}--#{generate_digest(data)}"
    end
  end
end

module ActionController
  module Session
    class CookieStore
      def verifier_for(secret, digest)
        key = secret.respond_to?(:call) ? secret.call : secret
        ActiveSupport::YamlMessageVerifier.new(key, digest)
      end
    end
  end
end