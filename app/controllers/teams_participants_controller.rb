class TeamsParticipantsController < ApplicationController

  def list
    @team = Team.find(params[:id])
    @assignment = Assignment.find(@team.assignment_id)
    @teams_participants = TeamsParticipant.page(page => params[:page]).per_page(10).where(["team_id = ?", params[:id]])
  end

  def new
    @team = Team.find(params[:id])
  end

  def create
    user = User.find_by_name(params[:user][:name].strip)
    if !user
      urlCreate = url_for :controller => 'users', :action => 'new'
      flash[:error] = "\"#{params[:user][:name].strip}\" is not defined. Please <a href=\"#{urlCreate}\">create</a> this user before continuing."
    end
    team = Team.find(params[:id])

    team.add_member(user, team.parent_id)

    #  flash[:error] = $!
    #end
    redirect_to :controller => 'teams', :action => 'list', :id => team.parent_id
end

def delete
  teamuser = TeamsParticipant.find(params[:id])
  parent_id = Team.find(teamuser.team_id).parent_id
  teamuser.destroy
  redirect_to :controller => 'teams', :action => 'list', :id => parent_id
end

def delete_selected
  params[:item].each {
    |item_id|
    team_user = TeamsParticipant.find(item_id).first
    team_user.destroy
  }

  redirect_to :action => 'list', :id => params[:id]
end

end
