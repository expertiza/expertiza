class ImpersonateController < ApplicationController
  include SecurityHelper

  def action_allowed?
    # Check for TA privileges first since TA's also have student privileges.
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

  # Method to overwrite the session details that are corresponding to the user or one being impersonated
  def overwrite_session
    # If not impersonatable, then original user's session remains
    if params[:impersonate].nil?
      # E1991 : check whether instructor is currently in anonymized view
      user = User.anonymized_view?(session[:ip]) ? User.real_user_from_anonymized_name(params[:user][:name]) : User.find_by(name: params[:user][:name])
      session[:super_user] = session[:user] if session[:super_user].nil?
      AuthController.clear_user_info(session, nil)
      session[:original_user] = @original_user
      session[:impersonate] = true
      session[:user] = user
    elsif !params[:impersonate][:name].empty?
      # E1991 : check whether instructor is currently in anonymized view
      user = User.anonymized_view?(session[:ip]) ? User.real_user_from_anonymized_name(params[:impersonate][:name]) : User.find_by(name: params[:impersonate][:name])
      AuthController.clear_user_info(session, nil)
      session[:user] = user
      session[:impersonate] = true
      session[:original_user] = @original_user
    else
      # E1991 : check whether instructor is currently in anonymized view
      AuthController.clear_user_info(session, nil)
      session[:user] = session[:super_user]
      session[:super_user] = nil
    end
  end

  # Checks if special characters are present in the username provided, only alphanumeric should be used
  # warn_for_special_chars is a method in SecurityHelper class.SecurityHelper class has methods to handle this.
  # special_chars method-Initialises string with special characters /\?<>|&$# .
  # contains_special_chars method-converts it to regex and compares with the string
  # warn_for_special_chars takes the output from above method and flashes an error if there are any special characters(/\?<>|&$#) in the string
  def check_if_special_char
    if params[:user]
      if warn_for_special_chars(params[:user][:name], 'Username')
        redirect_back
        return
      end
    end

    if params[:impersonate]
      if warn_for_special_chars(params[:impersonate][:name], 'Username')
        redirect_back
        return
      end
    end
  end

  # Checking if the username provided can be impersonated or not
  # If the user is in anonymized view,then fetch the real user else fetch the user using params
  # can_impersonate method in user.rb checks whether the original user can impersonate the other user in params
  # This method checks whether the user is a superadmin or teaching staff or recursively adds the child users till it reached highest hierarchy which is SuperAdmin
  # If original user can impersonate the user ,then session will be overwrite to get the view of the user who is getting impersonated
  def check_if_user_impersonateable
    if params[:impersonate].nil?
      # E1991 : check whether instructor is currently in anonymized view
      user = User.anonymized_view?(session[:ip]) ? User.real_user_from_anonymized_name(params[:user][:name]) : User.find_by(name: params[:user][:name])
      if !@original_user.can_impersonate? user
        @message = "You cannot impersonate '#{params[:user][:name]}'."
        temp
        AuthController.clear_user_info(session, nil)
      else
        overwrite_session
      end
    else
      unless params[:impersonate][:name].empty?
        # E1991 : check whether instructor is currently in anonymized view
        overwrite_session
      end
    end
  end

  # Function to display appropriate error messages based on different username provided, the message explains each error
  # This function checks params values and displays error_message based on the user name .This is initial check to see if username is valid
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
          @message = 'No original account was found. Please close your browser and start a new session.'
        end
      end
    end
  rescue StandardError
    flash[:error] = @message
    redirect_to :back
  end

  # Main operation
  def do_main_operation(user)
    if user
      check_if_user_impersonateable
    else
      display_error_msg
    end
  end

  # Main operation, method used to break the functions in impersonate controller and bring out 2 functionalities at same level,
  # checking if user impersonateable, if not throw corresponding error message
  def impersonate
    # Initial check to see if the username exists
    display_error_msg
    begin
      @original_user = session[:super_user] || session[:user]
      # Impersonate using form on /impersonate/start, based on the username provided, this method looks to see if that's possible by calling the do_main_operation method
      if params[:impersonate].nil?
        # Check if special chars /\?<>|&$# are used to avoid html tags or system command
        check_if_special_char
        # E1991 : check whether instructor is currently in anonymized view
        user = User.anonymized_view?(session[:ip]) ? User.real_user_from_anonymized_name(params[:user][:name]) : user = User.find_by(name: params[:user][:name])
        do_main_operation(user)
      else
        # Impersonate a new account
        if !params[:impersonate][:name].empty?
          # check if special chars /\?<>|&$# are used to avoid html tags or system command
          check_if_special_char
          # E1991 : check whether instructor is currently in anonymized view
          user = User.anonymized_view?(session[:ip]) ? User.real_user_from_anonymized_name(params[:impersonate][:name]) : User.find_by(name: params[:impersonate][:name])
          do_main_operation(user)
          # Revert to original account when currently in the impersonated session
        else
          if !session[:super_user].nil?
            AuthController.clear_user_info(session, nil)
            session[:user] = session[:super_user]
            user = session[:user]
            session[:super_user] = nil
          else
            display_error_msg
          end
        end
      end
      # Navigate to user's home location as the default landing page after impersonating or reverting
      AuthController.set_current_role(user.role_id, session)
      redirect_to action: AuthHelper.get_home_action(session[:user]),
                  controller: AuthHelper.get_home_controller(session[:user])
    rescue StandardError
      flash[:error] = @message
      redirect_to :back
    end
  end
end
