class PairProgrammingController < ApplicationController
  include AuthorizationHelper

  def action_allowed?
    current_user_has_student_privileges?
  end

  def send_invitations
    users = TeamsUser.where(team_id: params[:team_id])
    users.each { |user| user.update_attributes(pair_programming_status: "W") }
    TeamsUser.find_by(team_id: params[:team_id], user_id: current_user.id).update_attributes(pair_programming_status: "A")
    # ExpertizaLogger.info "Accepting Invitation #{params[:inv_id]}: #{accepted}"
    Team.find(params[:team_id]).update_attributes(pair_programming_request: 1)
    flash[:success] = "Invitations have been sent successfully!"
    redirect_to view_student_teams_path student_id: params[:student_id]
  end

  def accept
    user = TeamsUser.find_by(team_id: params[:team_id], user_id: current_user.id)
    user.update_attributes(pair_programming_status: "A")
    flash[:success] = "Pair Programming Request Accepted Successfully!"
    redirect_to view_student_teams_path student_id: params[:student_id]
  end

  def decline
    user = TeamsUser.find_by(team_id: params[:team_id], user_id: current_user.id)
    user.update_attributes(pair_programming_status: "D")
    Team.find(params[:team_id]).update_attributes(pair_programming_request: 0)
    flash[:success] = "Pair Programming Request Declined!"
    redirect_to view_student_teams_path student_id: params[:student_id]
  end
end
