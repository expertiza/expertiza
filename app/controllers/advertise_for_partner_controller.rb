class AdvertiseForPartnerController < ApplicationController
  def action_allowed?
    current_user.role.name.eql?("Student")
  end

  def new; end

  def create
    team = AssignmentTeam.find_by(id: params[:id])
    team.update_attributes(advertise_for_partner: true, comments_for_advertisement: params[:comments_for_advertisement])
    participant = AssignmentParticipant.find_by(parent_id: team.assignment.id, user_id: session[:user].id)
    redirect_to view_student_teams_path student_id: participant.id
  end

  def edit
    @team = AssignmentTeam.find_by(id: params[:team_id])
  end

  def update
    begin
      @team = AssignmentTeam.find_by(id: params[:id])
      @team.update_attributes(comments_for_advertisement: params[:comments_for_advertisement])
      participant = AssignmentParticipant.find_by(parent_id: @team.assignment.id, user_id: session[:user].id)
    rescue StandardError
      flash[:error] = 'An error occurred and your advertisement was not updated!'
      render action: 'edit'
    else
      flash[:success] = 'Your advertisement was successfully updated!'
      redirect_to view_student_teams_path student_id: participant.id
    end
  end

  def remove
    begin
      team = AssignmentTeam.find_by(id: params[:team_id])
      team.update_attributes(advertise_for_partner: false, comments_for_advertisement: nil)
      participant = AssignmentParticipant.find_by(parent_id: team.assignment.id, user_id: session[:user].id)
    rescue StandardError
      flash[:error] = 'An error occurred and your advertisement was not removed!'
      redirect_to :back
    else
      flash[:success] = 'Your advertisement was successfully removed!'
      redirect_to view_student_teams_path student_id: participant.id
    end
  end

  def team_params(params_hash)
    params_local = params
    params_local[:team] = params_hash unless nil == params_hash
    params_local.require(:team).permit(:id, :comments_for_advertisement)
  end
end
