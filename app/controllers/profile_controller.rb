class ProfileController < ApplicationController
  def action_allowed?
    current_user
  end

  def edit
    @user = session[:user]
    @assignment_questionnaire = AssignmentQuestionnaire.where('user_id = ? and assignment_id is null and questionnaire_id is null', @user.id).first
  end

  def update
    params.permit!
    @user = session[:user]
    # we tried to check weather we are able to fetch the home flag from the front end.
    # @username = session[:user].fullname
    # @prefernece = session[:user].preference_home_flag
    # if (session[:user].preference_home_flag)
    #   flash[:success] = 'Able to get'
    # end
    unless params[:assignment_questionnaire].nil? or params[:assignment_questionnaire][:notification_limit].blank?
      aq = AssignmentQuestionnaire.where(['user_id = ? and assignment_id is null and questionnaire_id is null', @user.id]).first
      aq.update_attribute('notification_limit', params[:assignment_questionnaire][:notification_limit])
    end
    if @user.update_attributes(params[:user])
      ExpertizaLogger.info LoggerMessage.new(controller_name, @user.name, "Your profile was successfully updated.", request)
      flash[:success] = 'Your profile was successfully updated.'
    else
      ExpertizaLogger.error LoggerMessage.new(controller_name, @user.name, "An error occurred and your profile could not updated.", request)
      flash[:error] = 'An error occurred and your profile could not updated.'
    end

    redirect_to controller: :profile, action: :edit
  end

  private
# we added two new flags preference_home_flag and preference_edit_flag for profile page to make user choose where he wants to see the options.
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
                                 :institution_id,
                                 :preference_home_flag,
                                 :preference_edit_flag)
  end
end
