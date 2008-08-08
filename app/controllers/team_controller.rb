class TeamController < ApplicationController
 auto_complete_for :user, :name  
   
 def list
   if params[:type]
    session[:team_type] = params[:type]
   end
   @root_node = Object.const_get(session[:team_type]+"Node").find_by_node_object_id(params[:id])   
   @child_nodes = @root_node.get_teams()
 end
 
 def new
   @parent = Object.const_get(session[:team_type]).find(params[:id])   
 end
 
 def create
   parent = Object.const_get(session[:team_type]).find(params[:id])
   begin
    check_for_existing_team_name(parent,params[:team][:name])
    team = Object.const_get(session[:team_type]+'Team').create(:name => params[:team][:name], :parent_id => parent.id)
    TeamNode.create(:parent_id => parent.id, :node_object_id => team.id)
    redirect_to :action => 'list', :id => parent.id
   rescue TeamExistsError
    flash[:error] = $! 
    redirect_to :action => 'new', :id => parent.id
   end
 end
 
 def update  
   team = Team.find(params[:id])
   parent = Object.const_get(session[:team_type]).find(team.parent_id)
   begin
    check_for_existing_team_name(parent,params[:team][:name])
    team.name = params[:team][:name]
    team.save
    redirect_to :action => 'list', :id => parent.id
   rescue TeamExistsError
    flash[:error] = $! 
    redirect_to :action => 'edit', :id => team.id
   end   
 end
 
 def edit
   @team = Team.find(params[:id])
 end
 
 def delete   
   team = Team.find(params[:id])
   course = Object.const_get(session[:team_type]).find(team.parent_id)
   team.delete
   redirect_to :action => 'list', :id => course.id
 end
 
 # Copies existing teams from a course down to an assignment
 # The team and team members are all copied.  
 def inherit
   assignment = Assignment.find(params[:id])
   if assignment.course_id > 0
    course = Course.find(assignment.course_id)
    teams = course.get_teams
    if teams.length > 0 
      teams.each{
        |team|
        team.copy(assignment.id)
      }
    else
      flash[:note] = "No teams were found to inherit."
    end
   else
     flash[:error] = "No course was found for this assignment."
   end
   redirect_to :controller => 'team', :action => 'list', :id => assignment.id   
 end
 
 # Copies existing teams from an assignment up to a course
 # The team and team members are all copied. 
 def bequeath
   team = AssignmentTeam.find(params[:id])
   assignment = Assignment.find(team.parent_id)
   if assignment.course_id
      course = Course.find(assignment.course_id)
      team.copy(course.id)
      flash[:note] = "\""+team.name+"\" was successfully copied to \""+course.name+"\""
   else
      flash[:error] = "This assignment is not #{url_for(:controller => 'assignment', :action => 'assign', :id => assignment.id)} with a course."
   end      
   redirect_to :controller => 'team', :action => 'list', :id => assignment.id
 end
 
 protected
 
 def check_for_existing_team_name(parent,name)
    model = Object.const_get(session[:team_type]+'Team')    
    list = model.find(:all, :conditions => ['parent_id = ? and name = ?',parent.id,name])
    if list.length > 0     
      raise TeamExistsError, 'Team name, "'+name+'", is already in use.'
    end
 end

 
end