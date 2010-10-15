class ImpersonateController < ApplicationController
  #auto_complete_for :user, :name
  
  def auto_complete_for_user_name     
     @users = session[:user].getAvailableUsers(params[:user][:name])        
     render :inline => "<%= auto_complete_result @users, 'name' %>", :layout => false
  end

  def start     
     
  end
 
  def impersonate 
    # default error message
    if params[:user] and params[:user][:name]
      message = "No user exists with the name '#{params[:user][:name]}'"
    end    
    
    begin
       # Initial impersonation
       if params[:impersonate].nil?
          user = User.find_by_name(params[:user][:name])
          if user
             if session[:super_user] == nil
                session[:super_user] = session[:user]
             end          
             AuthController.clear_user_info(session, nil)
             session[:user] = user
          else   
             flash[:error] = message
             raise
          end
       else
          # Impersonate a new account
          if params[:impersonate][:name].length > 0
             user = User.find_by_name(params[:impersonate][:name])
             if user
               AuthController.clear_user_info(session, nil)
               session[:user] = user          
             else    
               flash[:error] = message
               raise
             end                  
          # Revert to original account
          else      
             if session[:super_user] != nil
                AuthController.clear_user_info(session, nil)
                session[:user] = session[:super_user]                
                user = session[:user]
                session[:super_user] = nil               
             else
                flash[:error] = "No original account was found. Please close your browser and start a new session."
                raise
             end       
          end
       end   
       # Navigate to user's home location
       AuthController.set_current_role(user.role_id, session)   
       redirect_to :action => AuthHelper::get_home_action(session[:user]), 
                   :controller => AuthHelper::get_home_controller(session[:user])
    rescue
       
       redirect_to :back      
    end
 
  end
end
