class ProfileController < ApplicationController
  include AuthorizationHelper

  def action_allowed?
    user_logged_in?
  end

  def edit
    @user = session[:user]
    @assignment_questionnaire = AssignmentQuestionnaire.where('user_id = ? and assignment_id is null and questionnaire_id is null', @user.id).first
  end

  def update
    @user = session[:user]

    unless params[:assignment_questionnaire].nil? || params[:assignment_questionnaire][:notification_limit].blank?
      aq = AssignmentQuestionnaire.where(['user_id = ? and assignment_id is null and questionnaire_id is null', @user.id]).first
      aq.update_attribute('notification_limit', params[:assignment_questionnaire][:notification_limit])
    end
    if @user.update_attributes(user_params)
      ExpertizaLogger.info LoggerMessage.new(controller_name, @user.username, 'Your profile was successfully updated.', request)
      @user.etc_icons_on_homepage = params[:no_show_action] != 'not_show_actions'
      @user.save!
      flash[:success] = 'Your profile was successfully updated.'
    else
      ExpertizaLogger.error LoggerMessage.new(controller_name, @user.username, 'An error occurred and your profile could not updated.', request)
      flash[:error] = 'An error occurred and your profile could not updated.'
    end

    redirect_to controller: :profile, action: :edit
  end

  private

  def user_params
    params.require(:user).permit(:fullname,
                                 :password,
                                 :password_confirmation,
                                 :email,
                                 :institution_id,
                                 :email_on_review_of_review,
                                 :email_on_review,
                                 :email_on_submission,
                                 :handle,
                                 :timezonepref,
                                 :locale)
  end
end
