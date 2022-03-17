class TeamsController < ApplicationController
  include AuthorizationHelper

  autocomplete :user, :name

  def action_allowed?
    current_user_has_ta_privileges?
  end

  # attempt to initialize team type in session
  def init_team_type(type)
    if type and Team.allowed_types.include?(type)
      session[:team_type] = type
    end
  end

  # getter for retrieving team_type from session
  def team_type
    session[:team_type]
  end

  # This function is used to create teams with random names.
  # Instructors can call by clicking "Create teams" icon and then click "Create teams" at the bottom.
  def create_teams
    parent = Object.const_get(team_type).find(params[:id])
    Team.randomize_all_by_parent(parent, team_type, params[:team_size].to_i)
    undo_link('Random teams have been successfully created.')
    ExpertizaLogger.info LoggerMessage.new(controller_name, '', 'Random teams have been successfully created', request)
    redirect_to action: 'list', id: parent.id
  end

  def list
    init_team_type(params[:type])
    @assignment = Assignment.find_by(id: params[:id]) if team_type == 'Assignment'
    begin
      @root_node = Object.const_get(team_type + 'Node').find_by(node_object_id: params[:id])
      @child_nodes = @root_node.get_teams
    rescue StandardError
      flash[:error] = $ERROR_INFO
    end
  end

  def new
    @parent = Object.const_get(team_type ||= 'Assignment').find(params[:id])
  end

  # called when a instructor tries to create an empty team manually.
  def create
    parent = Object.const_get(team_type).find(params[:id])
    begin
      Team.check_for_existing(parent, params[:team][:name], team_type)
      @team = Object.const_get(team_type + 'Team').create(name: params[:team][:name], parent_id: parent.id)
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
    parent = Object.const_get(team_type).find(@team.parent_id)
    begin
      Team.check_for_existing(parent, params[:team][:name], team_type)
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

  def edit
    @team = Team.find(params[:id])
  end

  def delete_all
    root_node = Object.const_get(team_type + 'Node').find_by(node_object_id: params[:id])
    child_nodes = root_node.get_teams.map(&:node_object_id)
    Team.destroy_all(id: child_nodes) if child_nodes
    redirect_to action: 'list', id: params[:id]
  end

  def delete
    # delete records in team, teams_users, signed_up_teams table
    @team = Team.find_by(id: params[:id])
    unless @team.nil?
      @signed_up_team = SignedUpTeam.where(team_id: @team.id)
      @teams_users = TeamsUser.where(team_id: @team.id)

      if @signed_up_team == 1 && !@signUps.first.is_waitlisted # this team hold a topic
        # if there is another team in waitlist, make this team hold this topic
        topic_id = @signed_up_team.first.topic_id
        next_wait_listed_team = SignedUpTeam.where(topic_id: topic_id, is_waitlisted: true).first
        # if slot exist, then confirm the topic for this team and delete all waitlists for this team
        SignUpTopic.assign_to_first_waiting_team(next_wait_listed_team) if next_wait_listed_team
      end

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
    copy_teams(Team.team_operation[:inherit])
  end

  # Handovers all teams to the course that contains the corresponding assignment
  # The team and team members are all copied.
  def bequeath_all
    if team_type == 'Course'
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
