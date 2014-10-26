class AdvertiseForPartnerController < ApplicationController
  def action_allowed?
    current_user.role.name.eql?("Student")
  end

  #adds a new advertise for partners entry in team table...
  def new
  end

  #removes an entry from team table for corresponding team who requested to remove their advertisement for partner request
  def remove
    team = Team.find(params[:team_id])
    team.advertise_for_partner = false
    team.comments_for_advertisement = nil
    team.save

    assignment=Assignment.find(Team.find(params[:team_id]).parent_id)
    participant=AssignmentParticipant.where(parent_id: assignment.id, user_id: session[:user].id).first
    redirect_to view_student_teams_path student_id: participant.id
  end

  #update the team table with newly created advertise for partner request for the corresponding team
  def create
    team = Team.find(params[:id])
    team.advertise_for_partner = true
    team.comments_for_advertisement = params[:comments_for_advertisement]
    team.save

    assignment=Assignment.find(Team.find(params[:id]).parent_id)
    participant=AssignmentParticipant.where(parent_id: assignment.id, user_id: session[:user].id).first
    redirect_to view_student_teams_path student_id: participant.id
  end

  #update the advertisement when done with editing #####This should be edit rather than update....
  def update
    @team=Team.find(params[:id])
    #@team.comments_for_advertisement = params[:comments_for_advertisement]
    Team.update(params[:id], :comments_for_advertisement => params[:comments_for_advertisement])
    assignment=Assignment.find(Team.find(params[:id]).parent_id)
    participant=AssignmentParticipant.where(parent_id: assignment.id, user_id: session[:user].id).first
    if @team.save
      flash[:notice]='Advertisement updated successfully!'
      redirect_to view_student_teams_path student_id: participant.id
    else
      flash[:error]='Advertisement not updated!'
      redirect_to view_student_teams_path student_id: participant.id
    end
  end

  #find the team who wants to edit their advertisement
  def edit
    @team = Team.find(params[:team_id])
  end
end
