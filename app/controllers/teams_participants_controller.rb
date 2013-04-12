class TeamsParticipantsController < ApplicationController

  def auto_complete_for_user_name      
    team = Team.find(session[:team_id])    
    @users = team.get_possible_team_members(params[:user][:name])
    render :inline => "<%= auto_complete_result @users, 'name' %>", :layout => false
  end

  def list
    @team = Team.find_by_id(params[:id])
    @assignment = Assignment.find(@team.assignment_id)        
    @teams_participants = TeamsParticipant.paginate(:page => params[:page], :per_page => 10, :conditions => ["team_id = ?", params[:id]])
  end
  
  def new
    @team = Team.find_by_id(params[:id])    
  end
  
  def create    
    user = User.find_by_name(params[:user][:name].strip)
    if !user
      urlCreate = url_for :controller => 'users', :action => 'new'      
      flash[:error] = "\"#{params[:user][:name].strip}\" is not defined. Please <a href=\"#{urlCreate}\">create</a> this user before continuing."            
    end
    team = Team.find_by_id(params[:id])    
    
      team.add_member(user)
    
    #  flash[:error] = $!
    #end
    redirect_to :controller => 'team', :action => 'list', :id => team.parent_id
  end
        
  def delete
    teamuser = TeamsParticipant.find(params[:id])
    parent_id = Team.find(teamuser.team_id).parent_id
    teamuser.destroy    
    redirect_to :controller => 'team', :action => 'list', :id => parent_id   
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
