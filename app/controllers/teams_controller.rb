class TeamsController < ApplicationController
  autocomplete :user, :name

  def action_allowed?
    ['Instructor',
     'Teaching Assistant',
     'Administrator'].include? current_role_name
  end

  # This function is used to create teams with random names.
  # Instructors can call by clicking "Create temas" icon anc then click "Create teams" at the bottom.
  def create_teams
    parent = Object.const_get(session[:team_type]).find(params[:id])
    Team.randomize_all_by_parent(parent, session[:team_type], params[:team_size].to_i)
    undo_link("Random teams have been successfully created.")
    redirect_to action: 'list', id: parent.id
  end

  def list
    allowed_types = ['Assignment', 'Course']
    session[:team_type] = params[:type] if params[:type] && allowed_types.include?(params[:type])
    begin
      @root_node = Object.const_get(session[:team_type] + "Node").find_by_node_object_id(params[:id])
      @child_nodes = @root_node.get_teams
    rescue
      flash[:error] = $!
    end
  end

  def new
    @parent = Object.const_get(session[:team_type]).find(params[:id])
  end

  # called when a instructor tries to create an empty namually.
  def create
    parent = Object.const_get(session[:team_type]).find(params[:id])
    begin
      Team.check_for_existing(parent, params[:team][:name], session[:team_type])
      @team = Object.const_get(session[:team_type] + 'Team').create(name: params[:team][:name], parent_id: parent.id)
      TeamNode.create(parent_id: parent.id, node_object_id: @team.id)
      undo_link("The team \"#{@team.name}\" has been successfully created.")
      redirect_to action: 'list', id: parent.id
    rescue TeamExistsError
      flash[:error] = $ERROR_INFO
      redirect_to action: 'new', id: parent.id
    end
  end

  def update
    @team = Team.find(params[:id])
    parent = Object.const_get(session[:team_type]).find(@team.parent_id)
    begin
      Team.check_for_existing(parent, params[:team][:name], session[:team_type])
      @team.name = params[:team][:name]
      @team.save
      flash[:success] = "The team \"#{@team.name}\" has been successfully updated."
      undo_link("")
      redirect_to action: 'list', id: parent.id
    rescue TeamExistsError
      flash[:error] = $ERROR_INFO
      redirect_to action: 'edit', id: @team.id
    end
  end

  def edit
    @team = Team.find(params[:id])
  end

  def delete
    # delete records in team, teams_users, signed_up_teams table
    @team = Team.find(params[:id])
    course = Object.const_get(session[:team_type]).find(@team.parent_id)

    @signUps = SignedUpTeam.where(team_id: @team.id)

    @teams_users = TeamsUser.where(team_id: @team.id)

    if @signUps.size == 1 and @signUps.first.is_waitlisted == false # this team hold a topic
      # if there is another team in waitlist, make this team hold this topic
      topic_id = @signUps.first.topic_id
      next_wait_listed_team = SignedUpTeam.where(topic_id: topic_id, is_waitlisted: true).first
      # if slot exist, then confirm the topic for this team and delete all waitlists for this team
      if next_wait_listed_team
        SignUpTopic.assign_to_first_waiting_team(next_wait_listed_team)
      end
    end

    @signUps.destroy_all if @signUps
    @teams_users.destroy_all if @teams_users
    @team.destroy if @team

    undo_link("The team \"#{@team.name}\" has been successfully deleted.")
    redirect_to action: 'list', id: course.id
  end

  # Copies existing teams from a course down to an assignment
  # The team and team members are all copied.
  def inherit
    assignment = Assignment.find(params[:id])
    if assignment.course_id >= 0
      course = Course.find(assignment.course_id)
      teams = course.get_teams
      if !teams.empty?
        teams.each do |team|
          team.copy(assignment.id)
        end
      else
        flash[:note] = "No teams were found when trying to inherit."
      end
    else
      flash[:error] = "No course was found for this assignment."
    end
    redirect_to controller: 'teams', action: 'list', id: assignment.id
  end

  # Copies existing teams from an assignment up to a course
  # The team and team members are all copied.
  def bequeath
    team = AssignmentTeam.find(params[:id])
    assignment = Assignment.find(team.parent_id)
    if assignment.course_id >= 0
      course = Course.find(assignment.course_id)
      team.copy(course.id)
      flash[:note] = "The team \"" + team.name + "\" was successfully copied to \"" + course.name + "\""
    else
      flash[:error] = "This assignment is not #{url_for(controller: 'assignment', action: 'assign', id: assignment.id)} with a course."
    end
    redirect_to controller: 'teams', action: 'list', id: assignment.id
  end
end
