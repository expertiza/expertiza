class ProfileController < ApplicationController
  #added the below lines E913
  include AccessHelper
  before_filter :auth_check
  def action_allowed?
    if !current_user.nil?
      true
    end
  end
  def edit 
    @user = session[:user]
    @assignment_questionnaire = AssignmentQuestionnaire.first :conditions => ['user_id = ? and assignment_id is null and questionnaire_id is null', @user.id]
  end

  def update
    @user = session[:user]

    unless params[:assignment_questionnaire].nil? or params[:assignment_questionnaire][:notification_limit].blank?
      aq = AssignmentQuestionnaire.find(:first, :conditions => ['user_id = ? and assignment_id is null and questionnaire_id is null',@user.id])
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
