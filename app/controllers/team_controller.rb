require 'dl'
class TeamController < ApplicationController
   auto_complete_for :user, :name
   
  def list    
     unknown = params[:unknown]
     if unknown != nil && unknown.length > 0        
        str = 'The following logins were not added to a team: '
        for login in unknown
          str = str + login +' '
        end       
        flash[:note] = str
     end
     session[:assignment_id] = params[:assignment_id]
     
     @assignment = Assignment.find(session[:assignment_id])    
     @team_pages, @teams = paginate :teams, :conditions => ["assignment_id = ?",session[:assignment_id]], :per_page => 10
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
    @assignment = Assignment.find(params[:assignment_id])
    
    @team = Team.new 
  end

  def create
    check = Team.find(:all, :conditions => ["name =? and assignment_id =?", params[:team][:name], params[:assignment_id]])        
    @team = Team.new(params[:team])
    @team.assignment_id = params[:assignment_id]
    if (check.length == 0)      
      @team.save
      redirect_to :action => 'list', :assignment_id=> params[:assignment_id]
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
          redirect_to :action => 'list', :assignment_id=> params[:assignment_id]
       end
    elsif (check.length == 1 && check[0].name = params[:team][:name])
      redirect_to :action => 'list', :assignment_id=> params[:assignment_id]
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
    redirect_to :action => 'list', :unknown => unknown, :assignment_id=> params[:assignment_id]
  end  
  
  def list_assignments
    user_id = session[:user].id
    if (User.find_by_id(session[:user].id).role_id!=1)
      @assignments = Assignment.find(:all, :order => 'name',:conditions => ["instructor_id = ? and team_assignment =?", session[:user].id, 1])
    else
      @assignments = Assignment.find(:all, :order => 'name',:conditions => ["team_assignment =?", 1])
    end 
    
  end
  
  def delete_team
    @team = Team.find(params[:id])
    @team.delete
    redirect_to :action => 'list'
  end
end