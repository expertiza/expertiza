class ProfileController < ApplicationController
  def action_allowed?
    current_user
  end

  def edit
    @user = session[:user]
    @assignment_questionnaire = AssignmentQuestionnaire.where(['user_id = ? and assignment_id is null and questionnaire_id is null', @user.id]).first
  end

  def update
    params.permit!
    @user = session[:user]

    unless params[:assignment_questionnaire].nil? or params[:assignment_questionnaire][:notification_limit].blank?
      aq = AssignmentQuestionnaire.where(['user_id = ? and assignment_id is null and questionnaire_id is null',@user.id]).first
      aq.update_attribute('notification_limit',params[:assignment_questionnaire][:notification_limit])
    end

    if @user.update_attributes(params[:user])
      flash[:success] = 'Profile was successfully updated.'
    else
      flash[:error] = 'Profile was not updated.'
    end

    redirect_to controller: :profile, action: :edit
  end

  private
  # this is for strong parameters, but it is not used now. If you are planning to fix this, you can remove this line: "params.permit!"
  def user_params
    params.require(:user).permit(:name, :crypted_password, :role_id, :password_salt, :fullname, :email, :parent_id, :private_by_default, :mru_directory_path, :email_on_review, :email_on_submission, :email_on_review_of_review, :is_new_user, :master_permission_granted, :handle, :leaderboard_privacy, :digital_certificate, :persistence_token, :timezonepref, :public_key, :copy_of_emails)
  end
end
