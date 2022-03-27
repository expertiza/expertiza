class TeamsController < ApplicationController
  include AuthorizationHelper

  # documentation for the rails jquery autocomplete gem
  # can be found here https://github.com/crowdint/rails3-jquery-autocomplete-app
  autocomplete :user, :name

  # determines if something is allowed based on
  # whether the current user has TA privileges
  def action_allowed?
    current_user_has_ta_privileges?
  end

  # attempt to initialize team type in session
  def init_team_type(type)
    if type and Team.allowed_types.include?(type)
      session[:team_type] = type
    end
  end

  # retrieve an object's parent by its ID
  def get_parent_by_id(id)
    Object.const_get(session[:team_type]).find(id)
  end

  # retrieve an object's parent from the object's parent ID
  def get_parent_from_child(child)
    Object.const_get(session[:team_type]).find(child.parent_id)
  end

  # This function is used to create teams with random names.
  # Instructors can call by clicking "Create teams" icon and then click
  # the "Create teams" link at the bottom.
  def create_teams
    parent = get_parent_by_id(params[:id])
    Team.randomize_all_by_parent(parent, session[:team_type], params[:team_size].to_i)
    success_message = 'Random teams have been successfully created'
    undo_link(success_message)
    # To do: Move this check to a application level commons file.
    # For now this is the only usage of this check.
    # If a similar use case pops up "To do" action needs to be performed.
    # Fix link: https://tinyurl.com/y64bupbk
    if Rails.env.development?
      ExpertizaLogger.info LoggerMessage.new(controller_name, '', success_message, request)
    end
    redirect_to action: 'list', id: parent.id
  end

  # lists all teams associated with a specific assignment or course
  def list
    init_team_type(params[:type])
    @assignment = Assignment.find_by(id: params[:id]) if session[:team_type] == Team.allowed_types[0]
    @is_valid_assignment = session[:team_type] == Team.allowed_types[0] && @assignment.max_team_size > 1

    begin
      @root_node = Object.const_get(session[:team_type] + 'Node').find_by(node_object_id: params[:id])
      @child_nodes = @root_node.get_teams
    rescue StandardError
      flash[:error] = $ERROR_INFO
    end
  end

  # sets session and parent for new team form
  def new
    init_team_type(Team.allowed_types[0]) unless session[:team_type]
    @parent = Object.const_get(session[:team_type]).find(params[:id])
  end

  # called when a instructor tries to create an empty team manually.
  def create
    parent = get_parent_by_id(params[:id])
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

  # updates an existing team with user-entered changes
  def update
    @team = Team.find(params[:id])
    parent = get_parent_from_child(@team.parent_id)
    begin
      Team.check_for_existing(parent, params[:team][:name], session[:team_type])
      @team.name = params[:team][:name]
      @team.save
      flash[:success] = "The team \"#{@team.name}\" has been successfully updated."
      undo_link('')
      redirect_to action: 'list', id: parent.id
    rescue TeamExistsError
      flash[:error] = $ERROR_INFO
      redirect_to action: 'edit', id: @team.id
    end
  end

  # find team the user wants to edit so the view can populate the edit form
  def edit
    @team = Team.find(params[:id])
  end

  # delete all teams associated with a specific assignment or course
  def delete_all
    root_node = Object.const_get(session[:team_type] + 'Node').find_by(node_object_id: params[:id])
    child_nodes = root_node.get_teams.map(&:node_object_id)
    Team.destroy_all(id: child_nodes) if child_nodes
    redirect_to action: 'list', id: params[:id]
  end

  # delete a specific team from an assignment or course
  def delete
    # delete records in team, teams_users, signed_up_teams table
    @team = Team.find_by(id: params[:id])
    unless @team.nil?
      @signed_up_team = SignedUpTeam.where(team_id: @team.id)
      @teams_users = TeamsUser.where(team_id: @team.id)
      @sign_up_team.destroy_all if @sign_up_team
      @teams_users.destroy_all if @teams_users
      @team.destroy 
      undo_link("The team \"#{@team.name}\" has been successfully deleted.")
    end
    redirect_to :back
  end

  # Copies existing teams from a course down to an assignment
  # The team and team members are all copied.
  def inherit
    copy_teams(Team.team_operation[:inherit])
  end

  # Handovers all teams to the course that contains the corresponding assignment
  # The team and team members are all copied.
  def bequeath_all
    if session[:team_type] == Team.allowed_types[1]
      flash[:error] = 'Invalid team type for bequeath all'
      redirect_to controller: 'teams', action: 'list', id: params[:id]
    else
      copy_teams(Team.team_operation[:bequeath])
    end
  end

  private

  # Method to abstract the functionality to copy teams.
  def copy_teams(operation)
    assignment = Assignment.find(params[:id])
    if assignment.course_id
      choose_copy_type(assignment, operation)
    else
      flash[:error] = 'No course was found for this assignment.'
    end
    redirect_to controller: 'teams', action: 'list', id: assignment.id
  end

  # Method to choose copy technique based on the operation type.
  def choose_copy_type(assignment, operation)
    course = Course.find(assignment.course_id)
    if operation == Team.team_operation[:bequeath]
      bequeath_copy(assignment, course)
    else
      inherit_copy(assignment, course)
    end
  end

  # Method to perform a copy of assignment teams to course
  def bequeath_copy(assignment, course)
    teams = assignment.teams
    if course.course_teams.any?
      flash[:error] = 'The course already has associated teams'
    else
      Team.copy_content(teams, course)
      flash[:note] = teams.length.to_s + ' teams were successfully copied to "' + course.name + '"'
    end
  end

  # Method to inherit teams from course by copying
  def inherit_copy(assignment, course)
    teams = course.course_teams
    if teams.empty?
      flash[:error] = 'No teams were found when trying to inherit.'
    else
      Team.copy_content(teams, assignment)
      flash[:note] = teams.length.to_s + ' teams were successfully copied to "' + assignment.name + '"'
    end
  end

end
