class WritersController < ApplicationController

  def action_allowed?
    true
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    @user.role_id = 7
    @user.is_new_user = 1
    puts @user.to_s
    if @user.save
      flash[:success] = "Your account has been successfully created"
      render 'new.html.erb'
    else
      render 'new.html.erb'
    end
  end

  def user_params
    params.require(:user).permit(:name,
                                 :crypted_password,
                                 :role_id,
                                 :password_salt,
                                 :fullname,
                                 :email,
                                 :parent_id,
                                 :private_by_default,
                                 :mru_directory_path,
                                 :email_on_review,
                                 :email_on_submission,
                                 :email_on_review_of_review,
                                 :is_new_user,
                                 :master_permission_granted,
                                 :handle,
                                 :digital_certificate,
                                 :persistence_token,
                                 :timezonepref,
                                 :public_key,
                                 :copy_of_emails,
                                 :institution_id)
  end
end
