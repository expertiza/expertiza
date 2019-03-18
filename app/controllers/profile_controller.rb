class ProfileController < ApplicationController
  def action_allowed?
    current_user
  end

  def edit
    @user = session[:user]
    @assignment_questionnaire = AssignmentQuestionnaire.where('user_id = ? and assignment_id is null and questionnaire_id is null', @user.id).first
  end

  def update
    @user = session[:user]

    unless params[:assignment_questionnaire].nil? or params[:assignment_questionnaire][:notification_limit].blank?
      aq = AssignmentQuestionnaire.where(['user_id = ? and assignment_id is null and questionnaire_id is null', @user.id]).first
      aq.update_attributes(notification_limit: params[:assignment_questionnaire][:notification_limit])
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
end
