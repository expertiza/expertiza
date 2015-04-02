class ProfileController < ApplicationController
  def action_allowed?
    current_user
  end

  def edit
    @user = session[:user]
    @assignment_questionnaire = AssignmentQuestionnaire.where(['user_id = ? and assignment_id is null and questionnaire_id is null', @user.id]).first
  end

  def update
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
end
