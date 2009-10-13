class ImpersonateController < ApplicationController
  #auto_complete_for :user, :name
  
  def auto_complete_for_user_name     
     @users = session[:user].getAvailableUsers(params[:user][:name])        
     render :inline => "<%= auto_complete_result @users, 'name' %>", :layout => false
  end

  def start     
     
  end
 
  def impersonate 
     user = User.find_by_name(params[:user][:name])
     if user
        if session[:super_user] == nil
          session[:super_user] = session[:user]
        end
        
        AuthController.clear_user_info(session, nil)
        session[:user] = user
        AuthController.set_current_role(user.role_id, session)   
        redirect_to :action => AuthHelper::get_home_action(session[:user]), 
                    :controller => AuthHelper::get_home_controller(session[:user])
     else 
        flash[:error] = "No user exists with the name '#{params[:user][:name]}'"
        redirect_to :back
     end
   
  end
  
  def restore
      if session[:super_user] != nil
        AuthController.clear_user_info(session, nil)
        session[:user] = session[:super_user]
        session[:super_user] = nil       
        AuthController.set_current_role(session[:user].role_id, session)   
        redirect_to :action => AuthHelper::get_home_action(session[:user]), 
                    :controller => AuthHelper::get_home_controller(session[:user])
     else
        redirect_to :back
      end 
  end
end
