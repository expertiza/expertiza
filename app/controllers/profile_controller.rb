#Allows a user to update their own profile information
class ProfileController < ApplicationController

#load the view with the current fields
#only valid if user is logged in
 def edit 
    @user = session[:user]    
    @user.confirm_password = ''   
    @notification = NotificationLimit.find(:first, :conditions => ['user_id = ? and assignment_id is null and questionnaire_id is null',@user.id])     
 end
  
 #store parameters to user object
 def update
    @user = session[:user]
    
    if params[:notification] and params[:notification][:limit]
      notification = NotificationLimit.find(:first, :conditions => ['user_id = ? and assignment_id is null and questionnaire_id is null',@user.id])
      notification.limit = params[:notification][:limit]
      notification.save
    end
    
    if params[:user][:clear_password] == ''
      params[:user].delete('clear_password')
    end

    if params[:user][:clear_password] and
        params[:user][:clear_password].length > 0 and
        params[:user][:confirm_password] != params[:user][:clear_password]
      flash[:error] = 'Password does not match.'
      render :action => 'edit' 
    else
      if @user.update_attributes(params[:user])
        flash[:note] = 'Profile was successfully updated.'
        redirect_to :action => 'edit', :id => @user
      else
        flash[:note] = 'Profile was not updated.'
        render :action => 'edit'
      end
    end
  end

end
