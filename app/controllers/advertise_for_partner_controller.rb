class AdvertiseForPartnerController < ApplicationController
  include AuthorizationHelper

  def action_allowed?
    # Any user with at least a Student role should be able to advertise for a partner
    # For the create, edit, update, and remove actions the current user should also be a participant in the assignment
    # 'create' and 'update' are separated from 'edit' and 'remove' because they use different params
    case params[:action]

    when 'create', 'update'
      assignment = AssignmentTeam.find_by(id: params[:id]).assignment
      current_user_is_assignment_participant?(assignment.id) &&
        current_user_has_student_privileges?

    when 'edit', 'remove'
      assignment = AssignmentTeam.find_by(id: params[:team_id]).assignment
      current_user_is_assignment_participant?(assignment.id) &&
        current_user_has_student_privileges?

    else
      current_user_has_student_privileges?
    end
  end

  def new; end

  def create
    team = AssignmentTeam.find_by(id: params[:id])
    team.update_attributes(advertise_for_partner: true, comments_for_advertisement: params[:comments_for_advertisement])
    participant = AssignmentParticipant.find_by(parent_id: team.assignment.id, user_id: session[:user].id)
    ExpertizaLogger.info LoggerMessage.new(controller_name, session[:user].username, 'Your advertisement has been successfully created.', request)
    redirect_to view_student_teams_path student_id: participant.id
  end

  def edit
    @team = AssignmentTeam.find_by(id: params[:team_id])
  end

  def update
    @team = AssignmentTeam.find_by(id: params[:id])
    @team.update_attributes(comments_for_advertisement: params[:comments_for_advertisement])
    participant = AssignmentParticipant.find_by(parent_id: @team.assignment.id, user_id: session[:user].id)
  rescue StandardError
    ExpertizaLogger.error LoggerMessage.new(controller_name, session[:user].username, 'An error occurred and your advertisement was not updated.', request)
    flash[:error] = 'An error occurred and your advertisement was not updated!'
    render action: 'edit'
  else
    ExpertizaLogger.info LoggerMessage.new(controller_name, session[:user].username, 'Your advertisement has been successfully updated.', request)
    flash[:success] = 'Your advertisement was successfully updated!'
    redirect_to view_student_teams_path student_id: participant.id
  end

  def remove
    team = AssignmentTeam.find_by(id: params[:team_id])
    team.update_attributes(advertise_for_partner: false, comments_for_advertisement: nil)
    participant = AssignmentParticipant.find_by(parent_id: team.assignment.id, user_id: session[:user].id)
  rescue StandardError
    ExpertizaLogger.error LoggerMessage.new(controller_name, session[:user].username, 'An error occurred and your advertisement was not removed', request)
    flash[:error] = 'An error occurred and your advertisement was not removed!'
    redirect_back fallback_location: root_path
  else
    ExpertizaLogger.info LoggerMessage.new(controller_name, session[:user].username, 'Your advertisement has been successfully removed.', request)
    flash[:success] = 'Your advertisement was successfully removed!'
    redirect_to view_student_teams_path student_id: participant.id
  end
end
