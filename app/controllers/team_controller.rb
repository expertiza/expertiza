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
     if(session[:assignment_id] == nil)
         session[:assignment_id] = params[:id] 
     end     
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
    redirect_to :action => 'list'
  end

  def new
    @assignment = Assignment.find(session[:assignment_id])
    @team = Team.new 
  end

  def create
    check = Team.find(:all, :conditions => ["name =? and assignment_id =?", params[:team][:name], session[:assignment_id]])        
    @team = Team.new(params[:team])
    @team.assignment_id = session[:assignment_id]
    if (check.length == 0)      
      @team.save
      redirect_to :action => 'list'
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
          redirect_to :action => 'list'
       end
    else
      flash[:error] = 'Team name is already in use.'        
      render :action => 'edit'
    end 
  end
   
  def import_teams
    if params['load_teams']      
      file = params['uploaded_file']
      temp_directory = RAILS_ROOT + "/pg_data/tmp/#{session[:user].id}_"
      safe_filename = StudentAssignmentHelper::sanitize_filename(file.full_original_filename)
      File.open(temp_directory+safe_filename, "w") { |f| f.write(file.read) }   
      unknown = TeamHelper::upload_teams(temp_directory+safe_filename,session[:assignment_id],params[:options])       
      File.delete(temp_directory+safe_filename)      
    end  
    redirect_to :action => 'list', :unknown => unknown
  end  
  
  def list_assignments
    user_id = session[:user].id    
    @assignment_pages, @assignments = paginate :assignments, :order => 'name',:conditions => ["instructor_id = ? and team_assignment =?", session[:user].id, 1], :per_page => 10
  end
end