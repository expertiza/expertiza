class TeamController < ApplicationController
   auto_complete_for :user, :name
   
   def list_teams
    @team_pages, @teams = paginate :teams, :per_page => 10
  end

  def show_team
    @team = Team.find(params[:id])
  end

  def new_team
    @team = Team.new
  end
  
  def create
    @team = Team.new(params[:team])
    if @team.save
      flash[:notice] = 'Team was successfully created.'
      redirect_to :action => 'list_teams'
    else
      render :action => 'new_team'
    end
  end
  
    def edit
    @team = Team.find(params[:id])
  end

  def update
    @team = Team.find(params[:id])
    if @team.update_attributes(params[:team])
      flash[:notice] = 'Team was successfully updated.'
      redirect_to :action => 'show', :id => @team
    else
      render :action => 'edit'
    end
  end

  def destroy
    Team.find(params[:id]).destroy
    redirect_to :action => 'list_teams'
  end
  
  def view_team_members
    @team = Team.find(params[:id])
    @members = @team.teams_users
  end
  
    def add_team_member
    @team = Team.find(params[:team_id])
    @user = User.find_by_name(params[:user][:name])
    
      @team_user = TeamsUser.create(:team_id => @team.id, :user_id => @user.id)
      redirect_to :action => 'view_team_members', :id => @team
    
  end
end
