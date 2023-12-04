class TeamsController < ApplicationController
  include AuthorizationHelper

  autocomplete :user, :name

  # Check if the current user has TA privileges
  def action_allowed?
    current_user_has_ta_privileges?
  end

  # attempt to initialize team type in session
  def init_team_type(type)
    return unless type && Team.allowed_types.include?(type)

    session[:team_type] = type
  end

  # retrieve an object's parent by its ID
  def parent_by_id(id)
    Object.const_get(session[:team_type]).find(id)
  end

  # retrieve an object's parent from the object's parent ID
  def parent_from_child(child)
    Object.const_get(session[:team_type]).find(child.parent_id)
  end

  # This function is used to create teams with random names.
  # Instructors can call by clicking "Create teams" icon and then click "Create teams" at the bottom.
  def create_teams
    parent = find_parent(params[:id])
    create_random_teams(parent)
    log_team_creation
    redirect_to_team_list(parent.id)
  end

  def find_parent(id)
    parent_by_id(id)
  end
  
  def create_random_teams(parent)
    Team.randomize_all_by_parent(parent, session[:team_type], params[:team_size].to_i)
    undo_link('Random teams have been successfully created.')
  end
  
  def log_team_creation
    ExpertizaLogger.info LoggerMessage.new(controller_name, '', 'Random teams have been successfully created', request)
  end
  
  def redirect_to_team_list(parent_id)
    redirect_to action: 'list', id: parent_id
  end
  
  # Displays list of teams for a parent object(either assignment/course)

  def list
    init_team_type(params[:type])
    @assignment = find_assignment(params[:id]) if is_assignment?
    @is_valid_assignment = is_valid_assignment?
    begin
      set_team_nodes(params[:id])
    rescue StandardError
      flash[:error] = $ERROR_INFO
    end
  end
  
  def is_assignment?
    session[:team_type] == Team.allowed_types[0]
  end
  
  def find_assignment(id)
    Assignment.find_by(id: id)
  end
  
  def is_valid_assignment?
    is_assignment? && @assignment.max_team_size > 1
  end
  
  def set_team_nodes(id)
    @root_node = Object.const_get(session[:team_type] + 'Node').find_by(node_object_id: id)
    @child_nodes = @root_node.get_teams
  end
  

  # Create an empty team manually
  def new
    init_team_type(Team.allowed_types[0]) unless session[:team_type]
    @parent = Object.const_get(session[:team_type]).find(params[:id])
  end

  # Called when a instructor tries to create an empty team manually
    def create
    parent = find_parent(params[:id])
    begin
      create_team(parent)
      create_team_node(parent)
      set_undo_link_for_team_creation
      redirect_to_team_list(parent.id)
    rescue TeamExistsError
      handle_team_exists_error(parent.id)
    end
  end
  
  def find_parent(id)
    parent_by_id(id)
  end
  
  def create_team(parent)
    Team.check_for_existing(parent, params[:team][:name], session[:team_type])
    @team = Object.const_get(session[:team_type] + 'Team').create(name: params[:team][:name], parent_id: parent.id)
  end
  
  def create_team_node(parent)
    TeamNode.create(parent_id: parent.id, node_object_id: @team.id)
  end
  
  def set_undo_link_for_team_creation
    undo_link("The team \"#{@team.name}\" has been successfully created.")
  end
  
  def handle_team_exists_error(parent_id)
    flash[:error] = $ERROR_INFO
    redirect_to action: 'new', id: parent_id
  end
  
  # Update the team
  def update
    @team = find_team(params[:id])
    parent = parent_from_child(@team)
  
    begin
      update_team_name(parent, params[:team][:name])
      set_success_flash_for_update
      undo_link_for_update
      redirect_to_team_list(parent.id)
    rescue TeamExistsError
      handle_team_exists_error_for_update(@team.id)
    end
  end
  
  def find_team(id)
    Team.find(id)
  end
  
  def update_team_name(parent, new_name)
    Team.check_for_existing(parent, new_name, session[:team_type])
    @team.name = new_name
    @team.save
  end
  
  def set_success_flash_for_update
    flash[:success] = "The team \"#{@team.name}\" has been successfully updated."
  end
  
  def undo_link_for_update
    undo_link('')
  end
  
  def handle_team_exists_error_for_update(team_id)
    flash[:error] = $ERROR_INFO
    redirect_to action: 'edit', id: team_id
  end
  
  # Edit the team
  def edit
    @team = Team.find(params[:id])
  end

  # Deleting all teams associated with a given parent object
  def delete_all
    root_node = find_root_node(params[:id])
    child_nodes = get_child_node_ids(root_node)
  
    delete_teams(child_nodes) unless child_nodes.empty?
    redirect_to_team_list(params[:id])
  end
  
  def find_root_node(id)
    Object.const_get(session[:team_type] + 'Node').find_by(node_object_id: id)
  end
  
  def get_child_node_ids(root_node)
    root_node.get_teams.map(&:node_object_id)
  end
  
  def delete_teams(child_node_ids)
    Team.where(id: child_node_ids).destroy_all
  end

  # Deleting a specific team associated with a given parent object
  def delete
    @team = find_team_for_deletion(params[:id])
    return redirect_back(fallback_location: root_path) if @team.nil?

    handle_team_sign_ups(@team)
    delete_associated_records(@team)
    set_undo_link_for_deletion(@team.name)
    redirect_back(fallback_location: root_path)
  end

  def find_team_for_deletion(id)
    Team.find_by(id: id)
  end


  def handle_team_sign_ups(team)
    signed_up_team = SignedUpTeam.where(team_id: team.id).first
    return unless signed_up_team && !signed_up_team.is_waitlisted
  
    topic_id = signed_up_team.topic_id
    next_wait_listed_team = SignedUpTeam.where(topic_id: topic_id, is_waitlisted: true).first
    SignUpTopic.assign_to_first_waiting_team(next_wait_listed_team) if next_wait_listed_team
  end
  
  def delete_associated_records(team)
    signed_up_teams = SignedUpTeam.where(team_id: team.id)
    teams_users = TeamsUser.where(team_id: team.id)
  
    signed_up_teams.destroy_all if signed_up_teams.present?
    teams_users.destroy_all if teams_users.present?
    team.destroy
  end
  
  def set_undo_link_for_deletion(team_name)
    undo_link("The team \"#{team_name}\" has been successfully deleted.")
  end

  # Copies existing teams from a course down to an assignment
  # The team and team members are all copied.
  def inherit
    copy_teams(Team.team_operation[:inherit])
  end

  # Handovers all teams to the course that contains the corresponding assignment
  def bequeath_all
    return redirect_with_error if invalid_team_type_for_bequeath?
    copy_teams(Team.team_operation[:bequeath])
  end
  
  def invalid_team_type_for_bequeath?
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
      bequeath_copy(assignment, course)
    else
      inherit_copy(assignment, course)
    end
  end

  # Method to perform a copy of assignment teams to course
  def bequeath_copy(assignment, course)
    if course_has_teams?(course)
      set_flash_error('The course already has associated teams')
      return
    end
  
    copy_teams_to_course(assignment.teams, course)
  end
  
  # Method to inherit teams from course by copying
  def inherit_copy(assignment, course)
    if course_teams_empty?(course)
      set_flash_error('No teams were found when trying to inherit.')
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
  
  def copy_teams_to_course(teams, course)
    Team.copy_content(teams, course)
    set_flash_note("#{teams.length} teams were successfully copied to \"#{course.name}\"")
  end
  
  def copy_teams_to_assignment(teams, assignment)
    Team.copy_content(teams, assignment)
    set_flash_note("#{teams.length} teams were successfully copied to \"#{assignment.name}\"")
  end
  
  def set_flash_error(message)
    flash[:error] = message
  end
  
  def set_flash_note(message)
    flash[:note] = message
  end
end
