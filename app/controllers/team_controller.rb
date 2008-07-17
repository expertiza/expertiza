require 'dl'
class TeamController < ApplicationController
   auto_complete_for :user, :name
   
  def list        
     @assignment = Assignment.find(params[:id])        
     @teams = Team.find(:all, :conditions => ["assignment_id = ?",@assignment.id])     
  end
  
  def edit
    @team = Team.find(params[:id])
  end
  
  def destroy
    @team = Team.find(params[:id])
    for teamsuser in TeamsUser.find(:all, :conditions => ["team_id =?", @team.id])
       teamsuser.destroy
    end    
    @team.destroy
    redirect_to :action => 'list', :assignment_id=> params[:assignment_id]
  end

  def new
    @assignment = Assignment.find(params[:id])    
    @team = Team.new 
  end

  def create
    check = Team.find(:all, :conditions => ["name =? and assignment_id =?", params[:team][:name], params[:id]])        
    @team = Team.new(params[:team])
    @team.assignment_id = params[:id]
    if (check.length == 0)      
      @team.save
      redirect_to :action => 'list', :id=> params[:id]
    else
      flash[:error] = 'Team name is already in use.'        
      render :action => 'new'
    end 
  end
  
  def update
    @team = Team.find(params[:id])
    check = Team.find(:all, :conditions => ["name =? and assignment_id =?", params[:team][:name], @team.assignment_id])    
    if (check.length == 0)
       if @team.update_attributes(params[:team])
          redirect_to :action => 'list', :id => @team.assignment_id
       end
    elsif (check.length == 1 && check[0].name = params[:team][:name])
      redirect_to :action => 'list', :id => @team.assignment_id
    else
      flash[:error] = 'Team name is already in use.'        
      render :action => 'edit'
    end 
  end
   
  def import_teams
    if params['load_teams']      
      file = params['uploaded_file']
      unknown = TeamHelper::upload_teams(file,params[:assignment_id],params[:options],logger)           
    end  
    redirect_to :action => 'list', :unknown => unknown, :id=> params[:assignment_id]
  end  
  
  def list_assignments
    @assignments = Assignment.find(:all, :order => 'name',:conditions => ["instructor_id = ? and team_assignment =?", session[:user].id, 1])
  end
  
  def delete_team       
    @team = Team.find(params[:id])
    id = @team.assignment_id
    @team.delete
    redirect_to :action => 'list', :id => id 
  end
  
  def delete_selected
    params[:item].each {
      |team_id|      
      team = Team.find(team_id).first
      team.delete
    }
    
    redirect_to :action => 'list', :id => params[:id]
  end
end