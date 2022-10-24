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
    Team.randomize_all_by_parent(team_parent, team_type, team_size)

    success_message = 'Random teams have been successfully created.'
    ExpertizaLogger.info LoggerMessage.new(controller_name, '', success_message, request)
    undo_link(success_message)

    redirect_to action: 'list', id: team_parent.id
  end

  def list
    allowed_types = %w[Assignment Course]
    if params[:type] && allowed_types.include?(params[:type])
      session[:team_type] = params[:type]
    end

    @assignment = team_parent if session[:team_type] == 'Assignment'
    begin
      @root_node = Object.const_get(session[:team_type] + 'Node').find_by(node_object_id: params[:id])
      @child_nodes = @root_node.get_teams
    rescue StandardError
      flash[:error] = $ERROR_INFO
    end
  end

  def new
    session[:team_type] ||= 'Assignment'
    @parent = team_parent
  end

  # Called when a instructor tries to create an empty team manually
  def create
    check_for_existing_team

    @team = Object.const_get(session[:team_type] + 'Team').create(name: params[:team][:name], parent_id: team_parent.id)
    TeamNode.create(parent_id: team_parent.id, node_object_id: @team.id)

    undo_link("The team \"#{@team.name}\" has been successfully created.")
    redirect_to action: 'list', id: team_parent.id
  rescue TeamExistsError
    flash[:error] = $ERROR_INFO
    redirect_to action: 'new', id: team_parent.id
  end

  def update
    @team = Team.find(params[:id])
    begin
      check_for_existing_team

      @team.name = params[:team][:name]
      @team.save

      flash[:success] = "The team \"#{@team.name}\" has been successfully updated."
      undo_link('')
      redirect_to action: 'list', id: team_parent.id
    rescue TeamExistsError
      flash[:error] = $ERROR_INFO
      redirect_to action: 'edit', id: @team.id
    end
  end

  def edit
    @team = Team.find(params[:id])
  end

  def delete_all
    root_node = Object.const_get(session[:team_type] + 'Node').find_by(node_object_id: params[:id])
    child_nodes = root_node.get_teams.map(&:node_object_id)
    Team.destroy_all if child_nodes
    redirect_to action: 'list', id: params[:id]
  end

  def delete
    # delete records in team, teams_users, signed_up_teams table
    @team = Team.find_by(id: params[:id])
    unless @team.nil?
      @signed_up_team = SignedUpTeam.where(team_id: @team.id)
      @teams_users = TeamsUser.where(team_id: @team.id)

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
    if assignment.course_id
      course = Course.find(assignment.course_id)
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

  def team_size
    params[:team_size].to_i
  end

  # Gets the model representing the parent of the team
  def team_type
    if session[:team_type] == 'Assignment'
      Assignment
    elsif session[:team_type] == 'Course'
      Course
    end
  end

  # Finds the object containing the students
  # which the team will be generated from
  def team_parent
    @team_parent ||= team_type.find(params[:id])
  end

  # Raises a TeamExistsError if a team already
  # exists with the same parent and name
  def check_for_existing_team
    Team.check_for_existing(team_parent, params[:team][:name], session[:team_type])
  end
end
