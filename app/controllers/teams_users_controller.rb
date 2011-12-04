class TeamsUsersController < ApplicationController  

  def auto_complete_for_user_name      
    team = Team.find(session[:team_id])    
    @users = team.get_possible_team_members(params[:user][:name])
    render :inline => "<%= auto_complete_result @users, 'name' %>", :layout => false
  end

  def list
    @team = Team.find_by_id(params[:id])
    @assignment = Assignment.find(@team.assignment_id)        
    @teams_users = TeamsUser.paginate(:page => params[:page], :per_page => 10, :conditions => ["team_id = ?", params[:id]])
  end
  
  def new
    @team = Team.find_by_id(params[:id])    
  end

  def get_conflict_message(conflict)
    message = "Placing "
    message += conflict.second_person.handle
    message += " on this team will result in "
    message += conflict.first_person.handle

    if conflict.type == :max_duplicate_pairings

      message += " partnering with "
      message += conflict.second_person.handle
      message += " more than the allowed number of "
      message += conflict.threshold.to_s
      message += " times."
      return message

    elsif conflict.type == :min_unique_pairings

      message += " not meeting the requirement to have "
      message += conflict.threshold.to_s
      message += " different partners for this course."
      return message

    end
  end

  def create    
    user = User.find_by_name(params[:user][:name].strip)
    if !user
      urlCreate = url_for :controller => 'users', :action => 'new'      
      flash[:error] = "\"#{params[:user][:name].strip}\" is not defined. Please <a href=\"#{urlCreate}\">create</a> this user before continuing."
      redirect_to :action => 'new', :id => params[:id] and return
    end

    team = Team.find_by_id(params[:id])

    if !params[:force] and team.kind_of? AssignmentTeam
      participant = AssignmentParticipant.find(:first, :conditions => ['user_id = ? and parent_id = ?', user.id, team.parent_id])
      conflict = team.get_pairing_conflict(participant)

      if conflict
        flash[:warning] = render_to_string :partial => "warning", :locals => {
          :team => team,
          :user => user,
          :message => get_conflict_message(conflict)
        }
        redirect_to :action => 'new', :id => params[:id] and return
      end
    end

    team.add_member(user)

    #  flash[:error] = $!
    #end
    redirect_to :controller => 'team', :action => 'list', :id => team.parent_id
  end
        
  def delete
    teamuser = TeamsUser.find(params[:id])   
    parent_id = Team.find(teamuser.team_id).parent_id
    teamuser.destroy    
    redirect_to :controller => 'team', :action => 'list', :id => parent_id   
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
