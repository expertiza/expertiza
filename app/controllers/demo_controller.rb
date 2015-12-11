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



  def instruction_page

  end

  def proceed
    redirect_to :controller => 'tree_display', :action => 'list'
  end

  def create
    if simple_captcha_valid?

        check = User.find_by_name(params[:user][:name])
        if check != nil
        params[:user][:name] = params[:user][:email]
        end
        @user = User.new(user_params)
        if @user.save
        password = @user.reset_password         # the password is reset
        MailerHelper::send_mail_to_user(@user, "Your Expertiza account and password have been created", "user_welcome", password).deliver
        flash[:success] = "A new password has been sent to new user's e-mail address."
        redirect_to '/'
      else
        flash[:error] = "Please check on the credentials again and re enter."
        render :action => 'new'
      end
    else
      flash[:error] = "Please ENTER the correct CAPTCHA code"
      redirect_to '/'
    end
  end

  def show
  end

  def user_params
    params.require(:user).permit(:name, :crypted_password, :role_id, :password_salt, :fullname, :email, :parent_id, :private_by_default, :mru_directory_path, :email_on_review, :email_on_submission, :email_on_review_of_review, :is_new_user, :master_permission_granted, :handle, :leaderboard_privacy, :digital_certificate, :persistence_token, :timezonepref, :public_key, :copy_of_emails,:institutions_id)
  end
end
