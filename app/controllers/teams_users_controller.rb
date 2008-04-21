class TeamsUsersController < ApplicationController

  def list
    @team = Team.find_by_id(params[:id])
    @assignment = Assignment.find(@team.assignment_id)        
    @teams_users_pages, @teams_users = paginate :teams_user, :per_page => 10, :conditions => ["team_id = ?", params[:id]]
  end
  
  def new
    @team = Team.find_by_id(params[:id])    
  end
  
  def create    
    user = User.find_by_name(params[:user][:name].strip)
    team = Team.find_by_id(params[:id])
    if !user
      logger.info "No User found"
      urlCreate = url_for :controller => 'users', :action => 'new'
      flash[:error] = "\"#{params[:user][:name].strip}\" is not defined. Please <a href=\"#{urlCreate}\">create</a> this user before continuing."
      
    else
      check = TeamsUser.find(:all, :conditions => ["team_id =? and user_id =?",team.id,user.id])
      if (check.size > 0)
        flash[:error] = "\"#{user.name}\" is already a member of team \"#{team.name}\""
      else
        @teams_user = TeamsUser.new
        @teams_user.team_id = team.id
        @teams_user.user_id = user.id
        @teams_user.assignment_id = team.assignment_id
        @teams_user.save        
      end
      participants = Participant.find(:all, :conditions => ['assignment_id = ? and user_id = ?',team.assignment_id, user.id])
      if participants.length == 0
        Participant.create(:assignment_id => team.assignment_id, :user_id => user.id, :permission_granted => true)      
      end
    end
    redirect_to :action => 'list', :id => team.id
  end
  
  def delete_team_user
    @teamuser = TeamsUser.find(params[:id])   
    team_id = @teamuser.team_id
    @teamuser.destroy    
    redirect_to :action => 'list', :id => team_id    
  end   
  
 def auto_complete_for_user_name
  search = params[:user][:name].to_s
  @users = User.find_by_sql("select * from users where LOWER(name) LIKE '%"+search+"%' and id in (select user_id from participants where user_id not in (select user_id from teams_users where team_id in (select id from teams where assignment_id ="+session[:assignment_id]+")) and assignment_id ="+session[:assignment_id]+")") unless search.blank?
  render :partial => "members" 
 end

  def delete_selected
    params[:item].each {
      |item_id|      
      team_user = TeamsUser.find(item_id).first
      team_user.destroy
    }
    
    redirect_to :action => 'list', :id => params[:id]
  end
  
end
