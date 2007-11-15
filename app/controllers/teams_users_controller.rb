class TeamsUsersController < ApplicationController
  auto_complete_for :user, :name
  

  def list
    @team = Team.find_by_id(params[:id])
    @teams_users_pages, @teams_users = paginate :teams_user, :per_page => 10, :conditions => ["team_id = ?", params[:id]]
  end
  
  def new
    @team = Team.find_by_id(params[:id])
  end
  
  def create
    user = User.find_by_name(params[:user][:name])
    team = Team.find_by_id(params[:id])
    check = TeamsUser.find(:all, :conditions => ["team_id =? and user_id =?",team.id,user.id])
    if (check.size > 0)
      flash[:error] = "\"#{user.name}\" is already a member of team \"#{team.name}\""
    else
      @teams_user = TeamsUser.new
      @teams_user.team_id = team.id
      @teams_user.user_id = user.id
      @teams_user.save    
    end
    redirect_to :action => 'list', :id => team.id
  end
    
  def destroy
    @teamuser = TeamsUser.find(:all, :conditions => ["user_id =?",params[:id]]).first
    team_id = @teamuser.team_id
    @teamuser.destroy
    redirect_to :action => 'list', :id => team_id
  end
end
