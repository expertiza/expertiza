# frozen_string_literal: true

# TeamsController manages CRUD operations for teams, encompassing creation, updating, listing, and deletion.
# It includes methods associated with teams, leveraging helper modules for authorization and team-related functionalities.
class TeamsController < ApplicationController
  include AuthorizationHelper
  include TeamsControllerHelper

  autocomplete :user, :name

  # Checks if the current user has Teaching Assistant (TA) privileges
  def action_allowed?
    current_user_has_ta_privileges?
  end

  # Attempts to initialize the team type in the session
  def init_team_type(type)
    return unless type && Team.allowed_types.include?(type)

    session[:team_type] = type
  end

  # Retrieves an object's parent by its ID
  def find_parent_by_id(id)
    Object.const_get(session[:team_type]).find(id)
  end

  # Retrieves an object's parent from the object's parent ID
  def find_parent_from_child(child)
    Object.const_get(session[:team_type]).find(child.parent_id)
  end

  # Creates teams with random names, enabling instructors to create teams through a dedicated interface
  def create_teams
    parent = find_parent_by_id(params[:id])
    create_random_teams(parent)
    log_team_creation
    redirect_to_team_list(parent.id)
    rescue TeamExistsError => e
    handle_team_exists_error(parent.id, e.message)
  end

  # Displays a list of teams for a parent object (either an assignment or course)
  def list
    init_team_type(params[:type])
    @assignment = find_assignment(params[:id]) if assignment?
    @is_valid_assignment = valid_assignment?
    begin
      team_nodes(params[:id])
    rescue StandardError => e
      flash[:error] = "An error occurred: #{e.message}"
      # Log the error for investigation if needed
      Rails.logger.error("Error in TeamsController#list: #{e.message}")
    end
  end

  # Determines if the session type represents an assignment
  def assignment?
    session[:team_type] == Team.allowed_types[0]
  end

  # Finds an assignment by its ID
  def find_assignment(id)
    Assignment.find_by(id: id)
  end

  # Checks if the assignment is valid based on predefined conditions
  def valid_assignment?
    assignment? && @assignment.max_team_size > 1
  end

  # Sets team nodes associated with an ID
  def team_nodes(id)
    @root_node = Object.const_get("#{session[:team_type]}Node").find_by(node_object_id: id)
    @child_nodes = @root_node.get_teams
  end

  # Initializes creation of an empty team manually
  def new
    init_team_type(Team.allowed_types[0]) unless session[:team_type]
    @parent = Object.const_get(session[:team_type]).find(params[:id])
  end

  # Handles creation of a team manually by an instructor
  def create_team_manually
    parent = find_parent_by_id(params[:id])
    begin
      create_team(parent)
      create_team_node(parent)
      set_undo_link_for_team_creation
      redirect_to_team_list(parent.id)
    rescue TeamExistsError
      handle_team_exists_error(parent.id)
    end
  end

  # Updates team information
  def update
    @team = find_team(params[:id])
    parent = find_parent_from_child(@team)

    begin
      update_team_name(parent, params[:team][:name])
      set_success_flash_for_update
      undo_link_for_update
      redirect_to_team_list(parent.id)
    rescue TeamExistsError
      handle_team_exists_error_for_update(@team.id)
    end
  end

  # Finds a team by its ID
  def find_team(id)
    Team.find(id)
  end

  # Edits team details
  def edit
    @team = Team.find(params[:id])
  end

  # Deletes all teams associated with a given parent object
  def delete_all
    root_node = find_root_node(params[:id])
    child_nodes = get_child_node_ids(root_node)

    delete_teams(child_nodes) unless child_nodes.empty?
    redirect_to_team_list(params[:id])
  end

  # Finds the root node by its ID
  def find_root_node(id)
    Object.const_get("#{session[:team_type]}Node").find_by(node_object_id: id)
  end

  # Gets child node IDs associated with a root node
  def get_child_node_ids(root_node)
    root_node.get_teams.map(&:node_object_id)
  end

  # Deletes a specific team associated with a given parent object
  def delete
    @team = find_team_for_deletion(params[:id])
    return redirect_back(fallback_location: root_path) if @team.nil?

    handle_team_sign_ups(@team)
    delete_associated_records(@team)
    undo_link_for_deletion(@team.name)
    redirect_back(fallback_location: root_path)
  end

  # Finds a team for deletion by its ID
  def find_team_for_deletion(id)
    Team.find_by(id: id)
  end

  # Copies existing teams from a course down to an assignment, including team members
  def inherit
    copy_teams(Team.team_operation[:inherit])
  end

  # Transfers all teams to the course corresponding to the assignment
  def transfer_all
    return redirect_with_error if invalid_team_type_for_transfer?

    copy_teams(Team.team_operation[:bequeath])
    rescue StandardError => e
      flash[:error] = "An error occurred: #{e.message}"
    # Log the error for investigation if needed
      Rails.logger.error("Error in TeamsController#transfer_all: #{e.message}")
  end

  # Checks if the team type is invalid for transfer
  def invalid_team_type_for_transfer?
    session[:team_type] == Team.allowed_types[1]
  end

  def redirect_with_error
    flash[:error] = 'Invalid team type for bequeath all'
    redirect_to controller: 'teams', action: 'list', id: params[:id]
  end

  # Method to abstract the functionality to copy teams.
  def copy_teams(operation)
    assignment = find_assignment_for_copy(params[:id])
    if assignment.course_id
      choose_copy_type(assignment, operation)
    else
      flash_error_copy
    end
    redirect_to_team_list(assignment.id)
  end

  def find_assignment_for_copy(id)
    Assignment.find(id)
  end

  def flash_error_copy
    flash[:error] = 'No course was found for this assignment.'
  end

  def redirect_to_team_list_to_copy(assignment_id)
    redirect_to controller: 'teams', action: 'list', id: assignment_id
  end

  # Abstraction over different methods
  def choose_copy_type(assignment, operation)
    course = Course.find(assignment.course_id)
    if operation == Team.team_operation[:bequeath]
      transfer_copy(assignment, course)
    else
      inherit_copy(assignment, course)
    end
  end

  # Method to perform a copy of assignment teams to course
  def transfer_copy(assignment, course)
    if course_has_teams?(course)
      flash_error('The course already has associated teams')
      return
    end

    copy_teams_to_course(assignment.teams, course)
  end

  # Method to inherit teams from course by copying
  def inherit_copy(assignment, course)
    if course_teams_empty?(course)
      flash_error('No teams were found when trying to inherit.')
      return
    end

    copy_teams_to_assignment(course.course_teams, assignment)
  end

  def course_has_teams?(course)
    course.course_teams.any?
  end

  def course_teams_empty?(course)
    course.course_teams.empty?
  end
end
 
