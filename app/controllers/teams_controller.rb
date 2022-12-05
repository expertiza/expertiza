# frozen_string_literal: true

class TeamsController < ApplicationController
  include AuthorizationHelper

  autocomplete :user, :name

  before_action :ensure_course_team, only: %i[bequeath_all]

  # These routes can only be accessed by a TA
  def action_allowed?
    current_user_has_ta_privileges?
  end

  # Randomizes teams based on an Assignment or Course
  def randomize_teams
    Team.randomize_all_by_parent(team_type.find(params[:id]), session[:team_type], params[:team_size].to_i)

    success_message = 'Random teams have been successfully created.'
    undo_link(success_message)
    ExpertizaLogger.info LoggerMessage.new(controller_name, '', success_message, request)

    redirect_to action: 'list', id: params[:id]
  end

  # Set the list of a teams for an Assignment or Course for the view
  def list
    allowed_types = %w[Assignment Course]
    if params[:type] && allowed_types.include?(params[:type])
      session[:team_type] = params[:type]
    end

    @assignment = team_type.find(params[:id]) if session[:team_type] == 'Assignment'
    begin
      @root_node = get_team_type_const('Node').find_by(node_object_id: params[:id])
      @child_nodes = @root_node.get_teams
    rescue StandardError
      flash[:error] = $ERROR_INFO
    end
  end

  # Set the team parent for the new page
  def new
    session[:team_type] ||= 'Assignment'
    @parent = team_type.find(params[:id])
  end

  # Called when a instructor tries to create an empty team manually
  def create
    if check_for_existing_team do
      redirect_to action: 'new', id: params[:id]
    else
      @team = get_team_type_const('Team').create(name: params[:team][:name], parent_id: params[:id])
      TeamNode.create(parent_id: params[:id], node_object_id: @team.id)

      undo_link("The team \"#{@team.name}\" has been successfully created.")
      redirect_to action: 'list', id: params[:id]
    end
  end

  # Update a specific team and validate the new name
  def update
    @team = Team.find(params[:id])
    if check_for_existing_team do # Validate the new name
      redirect_to action: 'edit', id: @team.id
    else
      @team.name = params[:team][:name]
      @team.save

      flash[:success] = "The team \"#{@team.name}\" has been successfully updated."
      undo_link('')
      redirect_to action: 'list', id: params[:id]
    end
  end

  # Get the team for the team edit view
  def edit
    @team = Team.find(params[:id])
  end

  # TODO This method does not work
  # It should delete all teams for an assingment or course
  def delete_all
    root_node = get_team_type_const('Node').find_by(node_object_id: params[:id])
    child_nodes = root_node.get_teams.map(&:node_object_id)
    # BAD this will destroy all teams if it succeeds
    # Team.destroy_all if child_nodes
    redirect_to action: 'list', id: params[:id]
  end

  # Delete a specific team
  def delete
    # delete records in team, teams_users, signed_up_teams table
    @team = Team.find_by(id: params[:id])
    unless @team.nil?
      @signed_up_team = SignedUpTeam.where(team_id: @team.id)
      @teams_users = TeamsUser.where(team_id: @team.id)

      # remove deleted team from any waitlists
      Waitlist.remove_from_waitlists(@team.id)

      @sign_up_team&.destroy_all
      @teams_users&.destroy_all
      @team&.destroy
      undo_link("The team \"#{@team.name}\" has been successfully deleted.")
    end
    redirect_back fallback_location: root_path
  end

  # Copies existing teams from a course down to an assignment
  # The team and team members are all copied
  def copy_to_assignment
    assignment = Assignment.find(params[:id])
    course = assignment.course
    if course
      teams = course.get_teams
      if teams.empty?
        flash[:note] = 'No teams were found when trying to copy to assignment.'
      else
        Team.copy_teams_to_collection(teams, assignment.id)
      end
    else
      flash[:error] = 'No course was found for this assignment.'
    end
    redirect_to controller: 'teams', action: 'list', id: assignment.id
  end

  # Copies existing teams from an assignment to a
  # course if the course doesn't already have teams
  def bequeath_all
    assignment = Assignment.find(params[:id])
    course = Course.find(assignment.course_id) if assignment.course_id

    if !assignment.course_id
      flash[:error] = 'No course was found for this assignment.'
    elsif course.course_teams.any?
      flash[:error] = 'The course already has associated teams'
    else
      teams = assignment.teams
      Team.copy_teams_to_collection(teams, course.id)
      flash[:note] = teams.length.to_s + ' teams were successfully copied to "' + course.name + '"'
    end
    redirect_to controller: 'teams', action: 'list', id: assignment.id
  end

  private

  # Redirects if the team is not a CourseTeam
  def ensure_course_team
    if session[:team_type] == 'Course'
      flash[:error] = 'Invalid team type for bequeathal'
      redirect_to controller: 'teams', action: 'list', id: params[:id]
    end
  end

  # Gets the model representing the parent of the team
  def team_type
    if session[:team_type] == 'Assignment'
      Assignment
    elsif session[:team_type] == 'Course'
      Course
    end
  end

  # Raises a TeamExistsError if a team already
  # exists with the same parent and name
  def check_for_existing_team
    begin
      Team.check_for_existing(team_parent, params[:team][:name], session[:team_type])
      return false
    rescue TeamExistsError
      flash[:error] = $ERROR_INFO
      return true
  end

  # Checks for and returns the constant related to the team type.
  # Should either be 'Node' or 'Team'
  def get_team_type_const (const_type)
    Object.const_get(session[:team_type] + const_type)
  end
end
