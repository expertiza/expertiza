class AdvertiseForPartnerController < ApplicationController
  def new
    puts "team #{params[:team_id]}"
    Team.update_all("advertise_for_partner=true",:id=>params[:team_id])
  end

  def remove
    Team.update_all("advertise_for_partner=false",:id=>params[:team_id])
    assignment=Assignment.find(Team.find(params[:team_id]).parent_id)
    participant=Participant.find_by_parent_id_and_user_id(assignment.id,session[:user].id)
    redirect_to :controller => 'student_team', :action => 'view' , :id => participant.id
  end

  def add_advertise_comment
    Team.update(params[:id],:comments_for_advertisement => params[:comment].to_s)
    assignment=Assignment.find(Team.find(params[:id]).parent_id)
    participant=Participant.find_by_parent_id_and_user_id(assignment.id,session[:user].id)
    redirect_to :controller => 'student_team', :action => 'view' , :id => participant.id
  end

  def update
    @team=Team.find(params[:id])
    @team.comments_for_advertisement = params[:team][:comments_for_advertisement]
    assignment=Assignment.find(Team.find(params[:id]).parent_id)
    participant=Participant.find_by_parent_id_and_user_id(assignment.id,session[:user].id)
    if @team.save
      flash[:notice]='Advertisement edited successfully!'
      redirect_to :controller => 'student_team', :action => 'view' , :id => participant.id
    else
      flash[:error]='Advertisement not edited successfully!'
      redirect_to :controller => 'student_team', :action => 'view' , :id => participant.id
    end
  end

  def edit
    @team = Team.find(params[:team_id])
  end
end