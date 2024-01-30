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
    #E2351 - the current method for creating a team does not expand well for creating a subclass of either Assignment or Course Team so this is added logic to help allow for MentoredTeams to be created.
    #Team type is using for various purposes including creating nodes, but a MentoredTeam is an AssignmentTeam and still has a parent assignment, not a parent mentored so an additional variable needed to be created
    #to be able to separate object creation and the other things that :team_type was also used for. :create_team has been inserted into #create_teams and #create where needed
    session[:create_type] = type
    if type == 'Assignment'
      parent = parent_by_id(params[:id])
      if parent.auto_assign_mentor
        session[:create_type] = 'Mentored'
      end
    end
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
    #init_team_type(params[:type])
    parent = parent_by_id(params[:id])
    init_team_type(parent.class.name.demodulize)
    Team.randomize_all_by_parent(parent, session[:create_type], params[:team_size].to_i)
    undo_link('Random teams have been successfully created.')
    ExpertizaLogger.info LoggerMessage.new(controller_name, '', 'Random teams have been successfully created', request)
    redirect_to action: 'list', id: parent.id
  end

  # Displays list of teams for a parent object(either assignment/course)
  def list
    init_team_type(params[:type])
    @assignment = Assignment.find_by(id: params[:id]) if session[:team_type] == Team.allowed_types[0]
    unless @assignment.nil?
      if @assignment.auto_assign_mentor
        @model = MentoredTeam
      else
        @model = AssignmentTeam
      end
    end
    @is_valid_assignment = (session[:team_type] == Team.allowed_types[0]) && @assignment.max_team_size > 1
    begin
      @root_node = Object.const_get(session[:team_type] + 'Node').find_by(node_object_id: params[:id])
      @child_nodes = @root_node.get_teams
    rescue StandardError
      flash[:error] = $ERROR_INFO
    end
  end

  # Create an empty team manually
  def new
    init_team_type(Team.allowed_types[0]) unless session[:team_type]
    @parent = Object.const_get(session[:team_type]).find(params[:id])
  end

  # Called when a instructor tries to create an empty team manually
  def create
    #init_team_type(params[:type])
    parent = parent_by_id(params[:id])
    init_team_type(parent.class.name.demodulize)
    begin
      Team.check_for_existing(parent, params[:team][:name], session[:team_type])
      @team = Object.const_get(session[:create_type] + 'Team').create(name: params[:team][:name], parent_id: parent.id)
      TeamNode.create(parent_id: parent.id, node_object_id: @team.id)
      undo_link("The team \"#{@team.name}\" has been successfully created.")
      redirect_to action: 'list', id: parent.id
    rescue TeamExistsError
      flash[:error] = $ERROR_INFO
      redirect_to action: 'new', id: parent.id
    end
  end

  # Update the team
  def update
    @team = Team.find(params[:id])
    parent = parent_from_child(@team)
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

  # Edit the team
  def edit
    @team = Team.find(params[:id])
  end

  # Deleting all teams associated with a given parent object
  def delete_all
    root_node = Object.const_get(session[:team_type] + 'Node').find_by(node_object_id: params[:id])
    child_nodes = root_node.get_teams.map(&:node_object_id)
    Team.destroy_all if child_nodes
    redirect_to action: 'list', id: params[:id]
  end

  # Deleting a specific team associated with a given parent object
  def delete
    # delete records in team, teams_users, signed_up_teams table
    @team = Team.find_by(id: params[:id])
    unless @team.nil?
      @signed_up_team = SignedUpTeam.where(team_id: @team.id)
      @teams_users = TeamsUser.where(team_id: @team.id)

      if @signed_up_team == 1 && !@signUps.first.is_waitlisted # if a topic is assigned to this team
        # if there is another team in waitlist, assign this topic to the new team
        topic_id = @signed_up_team.first.topic_id
        next_wait_listed_team = SignedUpTeam.where(topic_id: topic_id, is_waitlisted: true).first
        # Save the topic's new assigned team and delete all waitlists for this team
        SignUpTopic.assign_to_first_waiting_team(next_wait_listed_team) if next_wait_listed_team
      end

      @sign_up_team.destroy_all if @sign_up_team
      @teams_users.destroy_all if @teams_users
      @team.destroy if @team
      undo_link("The team \"#{@team.name}\" has been successfully deleted.")
    end
    redirect_back fallback_location: root_path
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
