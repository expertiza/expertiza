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
    role = Role.student
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
