class AdvertiseForPartnerController < ApplicationController

  #adds a new advertise for partners entry in team table...
  def new
    puts "team #{params[:team_id]}"
    Team.update_all({:advertise_for_partner => true}, ["id = ?", params[:team_id]])
  end

  #removes an entry from team table for corresponding team who requested to remove their advertisement for partner request
  def remove
    Team.update_all({:advertise_for_partner => false}, ["id = ?", params[:team_id]])
    assignment=Assignment.find(Team.find(params[:team_id]).parent_id)
    participant=Participant.find_by_parent_id_and_user_id(assignment.id,session[:user].id)
    redirect_to :controller => 'student_team', :action => 'view' , :id => participant.id
  end

  #update the team table with newly created advertise for partner request for the corresponding team
  def add_advertise_comment
    Team.update(params[:id],:comments_for_advertisement => params[:comment].to_s)
    assignment=Assignment.find(Team.find(params[:id]).parent_id)
    participant=Participant.find_by_parent_id_and_user_id(assignment.id,session[:user].id)
    redirect_to :controller => 'student_team', :action => 'view' , :id => participant.id
  end

  #update the advertisement when done with editing #####This should be edit rather than update....
  def update
    @team=Team.find(params[:id])
    @team.comments_for_advertisement = params[:team][:comments_for_advertisement]
    assignment=Assignment.find(Team.find(params[:id]).parent_id)
    participant=Participant.find_by_parent_id_and_user_id(assignment.id,session[:user].id)
    if @team.save
      flash[:notice]='Advertisement updated successfully!'
      redirect_to :controller => 'student_team', :action => 'view' , :id => participant.id
    else
      flash[:error]='Advertisement not updated!'
      redirect_to :controller => 'student_team', :action => 'view' , :id => participant.id
    end
  end

  #find the team who wants to edit their advertisement
  def edit
    @team = Team.find(params[:team_id])
  end
end
