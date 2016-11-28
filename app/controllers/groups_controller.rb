class GroupsController < ApplicationController
  autocomplete :user, :name

  def action_allowed?
    ['Instructor',
     'Teaching Assistant',
     'Administrator'].include? current_role_name
  end

  # This function is used to create groups with random names.
  # Instructors can call by clicking "Create groups" icon anc then click "Create groups" at the bottom.
  def create_groups
    parent = Assignment.find(params[:id])
    Group.randomize_all_by_parent(parent, params[:group_size].to_i)
    undo_link("Random groups have been successfully created.")
    redirect_to action: 'list', id: parent.id
  end

  def list
    allowed_types = ['Assignment', 'Course']
    session[:group_type] = params[:type] if params[:type] && allowed_types.include?(params[:type])
    begin
      @root_node = Object.const_get("AssignmentNode").find_by_node_object_id(params[:id])
      @child_nodes = @root_node.get_groups
    rescue
      flash[:error] = $!
    end
  end

  def new
    @parent = Object.const_get(session[:group_type] ||= 'Assignment').find(params[:id])
  end

  # called when a instructor tries to create an empty namually.
  def create
    parent = Object.const_get(session[:group_type]).find(params[:id])
    begin
      Group.check_for_existing(parent, params[:group][:name], session[:group_type])
      @group = Object.const_get('Group').create(name: params[:group][:name], parent_id: parent.id)
      undo_link("The group \"#{@group.name}\" has been successfully created.")
      redirect_to action: 'list', id: parent.id
    rescue GroupExistsError
      flash[:error] = $ERROR_INFO
      redirect_to action: 'new', id: parent.id
    end
  end

  def update
    @group = Group.find(params[:id])
    parent = Object.const_get(session[:group_type]).find(@group.parent_id)
    begin
      Group.check_for_existing(parent, params[:group][:name], session[:group_type])
      @group.name = params[:group][:name]
      @group.save
      flash[:success] = "The group \"#{@group.name}\" has been successfully updated."
      undo_link("")
      redirect_to action: 'list', id: parent.id
    rescue GroupExistsError
      flash[:error] = $ERROR_INFO
      redirect_to action: 'edit', id: @group.id
    end
  end

  def edit
    @group = Group.find(params[:id])
  end

  def delete
    # delete records in group, groups_users, signed_up_groups table
    @group = Group.find(params[:id])
    course = Object.const_get(session[:group_type]).find(@group.parent_id)

    @sign_ups = SignedUpGroup.where(group_id: @group.id)

    @groups_users = GroupsUser.where(group_id: @group.id)

    if @sign_ups.size == 1 and @sign_ups.first.is_waitlisted == false # this group hold a topic
      # if there is another group in waitlist, make this group hold this topic
      topic_id = @sign_ups.first.topic_id
      next_wait_listed_group = SignedUpGroup.where(topic_id: topic_id, is_waitlisted: true).first
      # if slot exist, then confirm the topic for this group and delete all waitlists for this group
      if next_wait_listed_group
        SignUpTopic.assign_to_first_waiting_group(next_wait_listed_group)
      end
    end

    @sign_ups.destroy_all if @sign_ups
    @groups_users.destroy_all if @groups_users
    @group.destroy if @group

    undo_link("The group \"#{@group.name}\" has been successfully deleted.")
    redirect_to action: 'list', id: course.id
  end

  # Copies existing groups from a course down to an assignment
  # The group and group members are all copied.
  def inherit
    assignment = Assignment.find(params[:id])
    if assignment.course_id >= 0
      course = Course.find(assignment.course_id)
      groups = course.get_groups
      if !groups.empty?
        groups.each do |group|
          group.copy(assignment.id)
        end
      else
        flash[:note] = "No groups were found when trying to inherit."
      end
    else
      flash[:error] = "No course was found for this assignment."
    end
    redirect_to controller: 'groups', action: 'list', id: assignment.id
  end

  # Copies existing groups from an assignment up to a course
  # The group and group members are all copied.
  def bequeath
    group = AssignmentGroup.find(params[:id])
    assignment = Assignment.find(group.parent_id)
    if assignment.course_id >= 0
      course = Course.find(assignment.course_id)
      group.copy(course.id)
      flash[:note] = "The group \"" + group.name + "\" was successfully copied to \"" + course.name + "\""
    else
      flash[:error] = "This assignment is not #{url_for(controller: 'assignment', action: 'assign', id: assignment.id)} with a course."
    end
    redirect_to controller: 'groups', action: 'list', id: assignment.id
  end
end
