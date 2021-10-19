class TeamsController < ApplicationController
  include AuthorizationHelper

  autocomplete :user, :name

  def action_allowed?
    current_user_has_ta_privileges?
  end

  # This function is used to create teams with random names.
  # Instructors can call by clicking "Create temas" icon anc then click "Create teams" at the bottom.
  def create_teams
    parent = Team.create_teams(session,params)
    undo_link("Random teams have been successfully created.")
    ExpertizaLogger.info LoggerMessage.new(controller_name, '', 'Random teams have been successfully created', request)
    redirect_to action: 'list', id: parent.id
  end

  def list
    allowed_types = %w[Assignment Course]
    session[:team_type] = params[:type] if params[:type] && allowed_types.include?(params[:type])
    @assignment = Assignment.find_by(id: params[:id]) if session[:team_type] == 'Assignment'
    begin
      @root_node = Object.const_get(session[:team_type] + "Node").find_by(node_object_id: params[:id])
      @child_nodes = @root_node.get_teams
    rescue StandardError
      flash[:error] = $ERROR_INFO
    end
  end

  def new
    @parent = Object.const_get(session[:team_type] ||= 'Assignment').find(params[:id])
  end

  # called when a instructor tries to create an empty namually.
  def get_parent_and_check_if_exists(parent_id)
    parent = Object.const_get(session[:team_type]).find(params[:id])
    Team.check_for_existing(parent, params[:team][:name], session[:team_type])
    return parent
  end

  def catch_update_or_create_error(action, id)
    flash[:error] = $ERROR_INFO
    redirect_to action: action, id: id
  end

  def create
    begin
      parent = get_parent_and_check_if_exists(params[:id])
      @team = Object.const_get(session[:team_type] + 'Team').create(name: params[:team][:name], parent_id: parent.id)
      TeamNode.create(parent_id: parent.id, node_object_id: @team.id)
      undo_link("The team \"#{@team.name}\" has been successfully created.")
      redirect_to action: 'list', id: parent.id
    rescue TeamExistsError
      catch_update_or_create_error('new', parent_id)
    end
  end

  def update
    @team = Team.find(params[:id])
    begin
      parent = get_parent_and_check_if_exists(params[:id])
      @team.name = params[:team][:name]
      @team.save
      flash[:success] = "The team \"#{@team.name}\" has been successfully updated."
      undo_link("")
      redirect_to action: 'list', id: parent.id
    rescue TeamExistsError
      catch_update_or_create_error('edit', @team.id)
    end
  end

  def edit
    @team = Team.find(params[:id])
  end

  def delete
    # delete records in team, teams_users, signed_up_teams table
    @team = Team.find_by(id: params[:id])
    unless @team.nil?
      course = Object.const_get(session[:team_type]).find(@team.parent_id)
      @signed_up_team = SignedUpTeam.where(team_id: @team.id)
      @teams_users = TeamsUser.where(team_id: @team.id)

      SignedUpTeam.assign_topic_to_first_in_waitlist_post_team_deletion(@signed_up_team, @signups)

      @sign_up_team.destroy_all if @sign_up_team
      @teams_users.destroy_all if @teams_users
      @team.destroy if @team
      undo_link("The team \"#{@team.name}\" has been successfully deleted.")
    end
    redirect_to :back
  end

  # Copies existing teams from a course down to an assignment
  # The team and team members are all copied.
  def inherit
    assignment = Assignment.find(params[:id])
    if assignment.course_id >= 0
      course = Course.find(assignment.course_id)
      teams = course.get_teams
      unless teams.empty?
        Team.copyAssignment(teams,assignment)
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
