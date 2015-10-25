class TeamsController < ApplicationController
  autocomplete :user, :name


  def action_allowed?
    ['Instructor',
     'Teaching Assistant',
     'Administrator'].include? current_role_name
  end

  def create_teams_view
    @parent = Object.const_get(session[:team_type]).find(params[:id])
  end

  def delete_all
    parent = Object.const_get(session[:team_type]).find(params[:id])
    @teams = Team.where(parent_id: parent.id)
    @teams.each do |t|
      t.destroy
    end
    undo_link("All teams have been removed successfully. ")
    redirect_to :action => 'list', :id => parent.id
  end

  #This function is used to create teams with random names.
  def create_teams
    parent = Object.const_get(session[:team_type]).find(params[:id])
    Team.randomize_all_by_parent(parent, session[:team_type], params[:team_size].to_i)
    undo_link("Random teams have been created successfully. ")
    redirect_to :action => 'list', :id => parent.id
  end

  def list
    if params[:type]
      session[:team_type] = params[:type]
    end

    @root_node = Object.const_get(session[:team_type] + "Node").find_by_node_object_id(params[:id])
    @child_nodes = @root_node.get_teams()
  end

  def new
    @parent = Object.const_get(session[:team_type]).find(params[:id])
  end

  def create
    parent = Object.const_get(session[:team_type]).find(params[:id])
    begin
      Team.check_for_existing(parent, params[:team][:name], session[:team_type])
      @team = Object.const_get(session[:team_type]+'Team').create(:name => params[:team][:name], :parent_id => parent.id)
      TeamNode.create(:parent_id => parent.id, :node_object_id => @team.id)
      undo_link("Team \"#{@team.name}\" has been created successfully. ")
      redirect_to :action => 'list', :id => parent.id
    rescue TeamExistsError
      flash[:error] = $!
      redirect_to :action => 'new', :id => parent.id
    end
  end

  def update
    @team = Team.find(params[:id])
    parent = Object.const_get(session[:team_type]).find(@team.parent_id)
    begin
      Team.check_for_existing(parent, params[:team][:name], session[:team_type])
      @team.name = params[:team][:name]
      @team.save
      flash[:success] = "Team \"#{@team.name}\" has been updated successfully. "
      undo_link("")
      redirect_to :action => 'list', :id => parent.id
    rescue TeamExistsError
      flash[:error] = $!
      redirect_to :action => 'edit', :id => @team.id
    end
  end

  def edit
    @team = Team.find(params[:id])
  end

  def delete
    #delete records in team, teams_users, signed_up_teams table
    @team = Team.find(params[:id])
    course = Object.const_get(session[:team_type]).find(@team.parent_id)
    @team.destroy if @team
    @signUps = SignedUpTeam.where(team_id: params[:id])
    
    @teams_users = TeamsUser.where(team_id: params[:id])
    @teams_users.destroy_all if @teams_users

    if @signUps.size == 1 and @signUps.first.is_waitlisted == false #this team hold a topic
    #if there is another team in waitlist, make this team hold this topic
      topic_id = @signUps.first.topic_id
      next_wait_listed_team = SignedUpTeam.where({:topic_id => topic_id, :is_waitlisted => true}).first
      #if slot exist, then confirm the topic for this team and delete all waitlists for this team
      if next_wait_listed_team
        team_id = next_wait_listed_team.team_id
        team = Team.find(team_id)
        assignment_id = team.parent_id
        next_wait_listed_team.is_waitlisted = false
        next_wait_listed_team.save
        Waitlist.cancel_all_waitlists(team_id, assignment_id)
      end
    end
    @signUps.destroy_all if @signUps
    undo_link("Team \"#{@team.name}\" has been deleted successfully. ")
    redirect_to :action => 'list', :id => course.id
  end

  # Copies existing teams from a course down to an assignment
  # The team and team members are all copied.
  def inherit
    assignment = Assignment.find(params[:id])
    if assignment.course_id >= 0
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
    redirect_to :controller => 'teams', :action => 'list', :id => assignment.id
  end

  # Copies existing teams from an assignment up to a course
  # The team and team members are all copied.
  def bequeath
    team = AssignmentTeam.find(params[:id])
    assignment = Assignment.find(team.parent_id)
    if assignment.course_id >= 0
      course = Course.find(assignment.course_id)
      team.copy(course.id)
      flash[:note] = "\""+team.name+"\" was successfully copied to \""+course.name+"\""
    else
      flash[:error] = "This assignment is not #{url_for(:controller => 'assignment', :action => 'assign', :id => assignment.id)} with a course."
    end
    redirect_to :controller => 'teams', :action => 'list', :id => assignment.id
  end
end
