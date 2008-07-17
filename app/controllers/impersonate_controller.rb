class ImpersonateController < ApplicationController
  #auto_complete_for :user, :name
  
  def auto_complete_for_user_name       
     current_user = User.find(session[:user].id)
     @users = current_user.getAvailableUsers(params[:user][:name])        
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
        session[:user] = user 
        ImpersonateHelper::display_user_view(session,logger)     
        redirect_to :action => AuthHelper::get_home_action(session[:user]), 
                    :controller => AuthHelper::get_home_controller(session[:user])
     else 
        flash[:error] = "No user exists with the name '#{params[:user][:name]}'"
        redirect_to :back
     end
   
  end
  
  def restore
      if session[:super_user] != nil
        session[:user] = session[:super_user]
        session[:super_user] = nil
        ImpersonateHelper::display_user_view(session,logger)
        redirect_to :action => AuthHelper::get_home_action(session[:user]), 
                    :controller => AuthHelper::get_home_controller(session[:user])
     else
        redirect_to :back
      end 
  end
end
