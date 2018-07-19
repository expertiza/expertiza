class AuthController < ApplicationController
  helper :auth

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify method: :post, only: %i[login logout],
         redirect_to: {action: :list}

  def action_allowed?
    case params[:action]
    when 'login', 'logout', 'login_failed', 'google_login'
      true
    else
      current_role_name.eql?("Super-Administrator")
    end
  end

  def login
    if request.get?
      AuthController.clear_session(session)
    else
      user = User.find_by_login(params[:login][:name])
      if user and user.valid_password?(params[:login][:password])
        after_login(user)
      else
        ExpertizaLogger.error LoggerMessage.new(controller_name, "", 'Failed login attempt. Invalid username/password', request)
        flash[:error] = "Your username or password is incorrect."
        redirect_to controller: 'password_retrieval', action: 'forgotten'
      end
    end
  end # def login

  # function to handle common functionality for conventional user login and google login
  def after_login(user)
    session[:user] = user
    ExpertizaLogger.info LoggerMessage.new("", user.name, 'Login successful')
    AuthController.set_current_role(user.role_id, session)
    redirect_to controller: AuthHelper.get_home_controller(session[:user]),
                action: AuthHelper.get_home_action(session[:user])
  end

  # Login functionality for google login feature using omniAuth2
  def google_login
    g_email = env['omniauth.auth'].info.email
    user = User.find_by(email: g_email)
    if user.nil?
      ExpertizaLogger.error LoggerMessage.new(controller_name, g_email, 'This email is not authorized to use Expertiza!', request)
      flash[:error] = "This email is not authorized to use Expertiza!"
      redirect_to root_path
    else
      after_login(user)
    end
  end

  def login_failed
    flash.now[:error] = "Your username or password is incorrect."
    render action: 'forgotten'
  end

  def logout
    ExpertizaLogger.info LoggerMessage.new(controller_name, '', 'Logging out!', request)
    AuthController.logout(session)
    redirect_to '/'
  end

  def self.authorised?(session, params)
    authorised = false # default
    check_controller = false

    if params[:controller] == 'content_pages' and
      params[:action] == 'view'
      if session[:credentials].pages.key?(params[:page_name].to_s)
        authorised = true if session[:credentials].pages[params[:page_name].to_s] == true
      end
    else
      # Check if there's a specific permission for an action
      if session[:credentials].actions.key?(params[:controller])
        if session[:credentials].actions[params[:controller]].key?(params[:action]) and session[:credentials].actions[params[:controller]][params[:action]]
          authorised = true
        else
          check_controller = true
        end
      else
        check_controller = true
      end

      # Check if there's a general permission for a controller
      if check_controller
        authorised = true if session[:credentials].controllers.key?(params[:controller]) and session[:credentials].controllers[params[:controller]]
      end
    end # Check permissions

    ExpertizaLogger.info "Authorised? #{authorised}, check_controller? #{check_controller}"
    authorised
  end

  protected

  def self.logout(session)
    self.clear_session(session)
  end

  def self.set_current_role(role_id, session)
    if role_id
      role = Role.find role_id
      if role
        Role.rebuild_cache if !role.cache || !role.cache.try(:has_key?, :credentials)
        session[:credentials] = role.cache[:credentials]
        session[:menu] = role.cache[:menu]
        ExpertizaLogger.info "Logging in user as role #{session[:credentials].class}"
      else
        ExpertizaLogger.error "Something went seriously wrong with the role."
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

  # clears any identifying info from session
  def self.clear_user_info(session, assignment_id)
    session[:user_id] = nil
    session[:user] = "" # sets user to an empty string instead of nil, to show that the user was logged in
    role = Role.student
    if role
      Role.rebuild_cache if !role.cache or !role.cache.key?(:credentials)
      session[:credentials] = role.cache[:credentials]
      session[:menu] = role.cache[:menu]
    end
    session[:clear] = true
    session[:assignment_id] = assignment_id
  end
end
