class PairProgrammingController < ApplicationController
  include AuthorizationHelper
  before_action :set_team_and_user, only: [:send_invitations, :accept, :decline]

  def action_allowed?
    current_user_has_student_privileges?
  end

  def send_invitations
    update_pair_programming_status("W", "A", 1, "Invitations have been sent successfully!")
  end

  def accept
    update_status_and_redirect("A", nil, "Pair Programming Request Accepted Successfully!")
  end

  def decline
    update_status_and_redirect("D", 0, "Pair Programming Request Declined!")
  end

  private

  def set_team_and_user
    @team = Team.find(params[:team_id])
    @current_participant = @team.teams_participants.find_by(user_id: current_user.id)
  end

  def update_pair_programming_status(participant_status, current_participant_status, team_request, message)
    @team.teams_participants.update_all(pair_programming_status: participant_status) if participant_status
    update_status_and_redirect(current_participant_status, team_request, message)
  end

  def update_status_and_redirect(current_participant_status, team_request, message)
    @current_participant.update(pair_programming_status: current_participant_status) if current_participant_status
    @team.update(pair_programming_request: team_request) unless team_request.nil?
    flash[:success] = message
    redirect_to view_student_teams_path(student_id: params[:student_id])
  end
end
