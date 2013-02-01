# GoldbergFilters


module GoldbergFilters

  def goldberg_security_filter
    @settings = SystemSettings.find(:first)

    if @settings
      make_public = false  # Going to check if we need to

      # Work around a bug that causes session[:credentials] to become a YAML Object
      session[:credentials] = nil if session[:credentials].is_a? YAML::Object

      # If there's already a session, check that it's still up to date
      if session[:credentials] and session[:credentials].role_id
        role = Role.find(session[:credentials].role_id)
        if role
          # Check if the role has been updated
          if role.updated_at > session[:credentials].updated_at
            menu_selection = session[:menu].selected  # remember this
            session[:credentials] = role.cache[:credentials]
            session[:menu] = role.cache[:menu]
            if menu_selection
              session[:menu].select(menu_selection)
            end
          else
            # Role is still current: no action required here
            logger.info "(Role still current)"
          end
        else  # No such Role: must have been deleted?
          make_public = true
        end
      else  # No credentials
        make_public = true
      end

      if make_public
        public_role = Role.find(@settings.public_role_id)
        if not public_role or not public_role.cache or 
            not public_role.cache[:credentials] or 
            not public_role.cache[:menu] or
            public_role.cache[:credentials].is_a?(YAML::Object) or
            public_role.cache[:menu].is_a?(YAML::Object)
          Role.rebuild_cache
          public_role = Role.find(@settings.public_role_id)
        end

        session[:credentials] = public_role.cache[:credentials]
        session[:menu] = public_role.cache[:menu]
      end
      
      if session[:credentials].role_id != @settings.public_role_id
        logger.info "(Logged-in user)"
        if session[:last_time] != nil
          if (Time.now - session[:last_time]) > @settings.session_timeout
            logger.info "Session: time expired"
            AuthController.logout(session)
            redirect_to @settings.session_expired_page.url
            return false
          else
            logger.info "Session: time NOT expired"
          end
        end
      end
      
      # If this is a page request check that it exists, and if not
      # redirect to the "unknown" page
      if params[:controller] == 'content_pages' and
          params[:action] == 'view'
        if not session[:credentials].pages.has_key?(params[:page_name].to_s)
          logger.warn "(Unknown page? #{params[:page_name].to_s})"
          redirect_to @settings.not_found_page.url
          return false
        end
      end

      # PERMISSIONS
      # Check whether the user is authorised for this page or action.
      if not AuthController.authorised?(session, params)
        redirect_to @settings.permission_denied_page.url
        return false
      end
    end  # if @settings
    
    session[:last_time] = Time.now
    
    return true
  end
end


ActionController::Base.class_eval do
  include GoldbergFilters
  append_before_filter :goldberg_security_filter
end
