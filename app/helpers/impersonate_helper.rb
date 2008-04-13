module ImpersonateHelper
  def self.display_user_view(session,logger)
    user = session[:user]
    if user.role_id
          role = Role.find(user.role_id)
          if role
            if not role.cache or not role.cache.has_key?(:credentials)
              Role.rebuild_cache
            end
            session[:menu] = role.cache[:menu]
            logger.info "Impersonating user as role #{session[:credentials].class}"
          else
            logger.error "Something went seriously wrong with the role"
          end
      end     
  end 
end
