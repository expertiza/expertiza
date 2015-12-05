class DemoController < ApplicationController
  skip_before_filter  :verify_authenticity_token

  def action_allowed?
    true
  end

  def new
     @demo_role = Role.find_by_name("demo_instructor")
    if @demo_role
         @user = User.new
          @demo_role_id = @demo_role.id
    else
      flash[:error] = "Demo Instructor Role not yet created"
      redirect_to '/'
    end
   
    
  end



  def place_holder

  end

  def proceed
    redirect_to :controller => 'tree_display', :action => 'list'
  end

  def create
    if simple_captcha_valid?


        # if the user name already exists, register the user by email address
        check = User.find_by_name(params[:user][:name])
        if check != nil
        params[:user][:name] = params[:user][:email]
        end

      @user = User.new(user_params)
     # @super_admin = User.find_by_name("Super-Administrator")


      if @user.save
        password = @user.reset_password         # the password is reset
        MailerHelper::send_mail_to_user(@user, "Your Expertiza account and password have been created", "user_welcome", password).deliver

        flash[:success] = "A new password has been sent to new user's e-mail address."
        #Instructor and Administrator users need to have a default set for their notifications
        # the creation of an AssignmentQuestionnaire object with only the User ID field populated
        # ensures that these users have a default value of 15% for notifications.
        #TAs and Students do not need a default. TAs inherit the default from the instructor,
        # Students do not have any checks for this information.
        #if @user.role.name == "Instructor" or @user.role.name == "Administrator"
        #  AssignmentQuestionnaire.create(:user_id => @user.id)
        #end
        #undo_link("User \"#{@user.name}\" has been created successfully. ")
        #redirect_to :controller => 'content_pages', :action => 'view'
        redirect_to '/'
      else
        flash[:error] = "Please check on the credentials again and re enter."
        render :action => 'new'
      end

    else
      flash[:error] = "Please ENTER the correct CAPTCHA code"
      render :action => 'new'
    end

  end

  def show
  end

  def user_params
    params.require(:user).permit(:name, :crypted_password, :role_id, :password_salt, :fullname, :email, :parent_id, :private_by_default, :mru_directory_path, :email_on_review, :email_on_submission, :email_on_review_of_review, :is_new_user, :master_permission_granted, :handle, :leaderboard_privacy, :digital_certificate, :persistence_token, :timezonepref, :public_key, :copy_of_emails,:institutions_id)
  end
end
