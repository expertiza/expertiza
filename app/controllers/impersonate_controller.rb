
class ImpersonateController < ApplicationController
  include SecurityHelper

  def action_allowed?
    if ['Student'].include? current_role_name
      !session[:super_user].nil?
    else
      ['Super-Administrator',
       'Administrator',
       'Instructor',
       'Teaching Assistant'].include? current_role_name
    end
  end

  def auto_complete_for_user_name
    @users = session[:user].get_available_users(params[:user][:name])
    render inline: "<%= auto_complete_result @users, 'name' %>", layout: false
  end

  def start
    flash[:error] = "This page doesn't take any query string." unless request.GET.empty?
  end

<<<<<<< HEAD
  # method to clear the session 
  def clear_session
    #original_user = session[:super_user] || session[:user]
    #user = User.find_by(name: params[:user][:name])
    #AuthController.clear_user_info(session, nil)

    if params[:impersonate].nil?
          user = User.find_by(name: params[:user][:name])
          session[:super_user] = session[:user] if session[:super_user].nil?
      	  AuthController.clear_user_info(session, nil)
          session[:original_user] = @original_user
          session[:impersonate] = true
          session[:user] = user
    else
          
          if !params[:impersonate][:name].empty?
	    user = User.find_by(name: params[:impersonate][:name])
            #user = User.find_by(name: params[:impersonate][:name])
	    AuthController.clear_user_info(session, nil)
            session[:user] = user
            session[:impersonate] =  true
            session[:original_user] = @original_user
          else
            user = User.find_by(name: params[:user][:name])
	    AuthController.clear_user_info(session, nil)
            session[:user] = session[:super_user]
            user = session[:user]
            session[:super_user] = nil
          end
    end
   end

  # checking if special character 
  def check_if_spl_char
    if warn_for_special_chars(params[:user][:name], "Username")
          redirect_back
          return
    end
  end
 
  # When specified user cannot be impersonated
  def checkif_user_impersonateable 
    #original_user = session[:super_user] || session[:user]
    if params[:impersonate].nil?
           user = User.find_by(name: params[:user][:name])
          if @original_user.can_impersonate? user
            flash[:error] = "You cannot impersonate #{params[:user][:name]}."
            #redirect_back
            #return
	  end
    else 
           if !params[:impersonate][:name].empty?
              user = User.find_by(name: params[:impersonate][:name])
           end
    end

  end 

  # Function to display appropriate error messages 
  def display_error_msg
    if params[:user]
      @message = "No user exists with the name '#{params[:user][:name]}'."
    elsif params[:impersonate]
      @message = "No user exists with the name '#{params[:impersonate][:name]}'."
    
    else	 
      if params[:impersonate].nil?
           @message = "You cannot impersonate '#{params[:user][:name]}'."
      else
           if !params[:impersonate][:name].empty?
              @message = "You cannot impersonate '#{params[:impersonate][:name]}'."
           else
              @message = "No original account was found. Please close your browser and start a new session."
           end 
       end
    end
    rescue Exception => e
      flash[:error] = @message
      redirect_to :back

  end
    
   
  # Method to be refactored
  def impersonate
      display_error_msg
      begin
      @original_user = session[:super_user] || session[:user]

=======
  def impersonate
    if params[:user]
      message = "No user exists with the name '#{params[:user][:name]}'."
    elsif params[:impersonate]
      message = "No user exists with the name '#{params[:impersonate][:name]}'."
    end
    begin
      original_user = session[:super_user] || session[:user]
>>>>>>> 13ace7fccaaba2a97058ee6c282225f4e4b40962
      # Impersonate using form on /impersonate/start
      if params[:impersonate].nil?
        # check if special chars /\?<>|&$# are used to avoid html tags or system command
        if warn_for_special_chars(params[:user][:name], "Username")
          redirect_back
          return
        end
        user = User.find_by(name: params[:user][:name])
        if user
          unless original_user.can_impersonate? user
            flash[:error] = "You cannot impersonate #{params[:user][:name]}."
            redirect_back
            return
          end
          session[:super_user] = session[:user] if session[:super_user].nil?
          AuthController.clear_user_info(session, nil)
          session[:original_user] = original_user
          session[:impersonate] = true
          session[:user] = user
        else
          flash[:error] = message
          redirect_back
          return
        end
      else
        # Impersonate a new account
        if !params[:impersonate][:name].empty?
          # check if special chars /\?<>|&$# are used to avoid html tags or system command
          if warn_for_special_chars(params[:impersonate][:name], "Username")
            redirect_back
            return
          end
          user = User.find_by(name: params[:impersonate][:name])
          if user
            unless original_user.can_impersonate? user
              flash[:error] = "You cannot impersonate #{params[:user][:name]}."
              redirect_back
              return
            end
            AuthController.clear_user_info(session, nil)
            session[:user] = user
            session[:impersonate] =  true
            session[:original_user] = original_user
          else
            flash[:error] = message
            redirect_back
            return
          end
          # Revert to original account
        else
          if !session[:super_user].nil?
            AuthController.clear_user_info(session, nil)
            session[:user] = session[:super_user]
            user = session[:user]
            session[:super_user] = nil
          else
            flash[:error] = "No original account was found. Please close your browser and start a new session."
            redirect_back
            return
          end
        end
      end
      # Navigate to user's home location
      AuthController.set_current_role(user.role_id, session)
      redirect_to action: AuthHelper.get_home_action(session[:user]),
                  controller: AuthHelper.get_home_controller(session[:user])
    rescue Exception => e
      flash[:error] = e.message
      redirect_to :back
    end
  end
end