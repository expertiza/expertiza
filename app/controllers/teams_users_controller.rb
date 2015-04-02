class TeamsUsersController < ApplicationController

  def action_allowed?
    ['Instructor',
     'Teaching Assistant',
     'Administrator'].include? current_role_name
  end

  def auto_complete_for_user_name
    team = Team.find(session[:team_id])
    @users = team.get_possible_team_members(params[:user][:name])
    render :inline => "<%= auto_complete_result @users, 'name' %>", :layout => false
  end

  def list
    @team = Team.find(params[:id])
    @assignment = Assignment.find(@team.assignment_id)
    @teams_users = TeamsUser.page(params[:page]).per_page(10).where(["team_id = ?", params[:id]])
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

    add_member_return=team.add_member(user, team.parent_id)
    if add_member_return==false
      flash[:error]= "The team already has the maximum number of members."
    end

    @teams_user = TeamsUser.last
    undo_link("Team user \"#{user.name}\" has been added to \"#{team.name}\" successfully. ")

    redirect_to :controller => 'teams', :action => 'list', :id => team.parent_id
  end

  def delete
    @teams_user = TeamsUser.find(params[:id])
    parent_id = Team.find(@teams_user.team_id).parent_id
    @user = User.find(@teams_user.user_id)
    @teams_user.destroy
    undo_link("Team user \"#{@user.name}\" has been removed successfully. ")
    redirect_to :controller => 'teams', :action => 'list', :id => parent_id
  end

  def delete_selected
    params[:item].each {
      |item_id|
      team_user = TeamsUser.find(item_id).first
      team_user.destroy
    }

    redirect_to :action => 'list', :id => params[:id]
  end

  #def undo_link
  #  "<a href = #{url_for(:controller => :versions,:action => :revert,:id => @teams_user.versions.last.id)}>undo</a>"
  #end



end
