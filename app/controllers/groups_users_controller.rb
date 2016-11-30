class GroupsUsersController < ApplicationController
  def action_allowed?
    ['Instructor',
     'Teaching Assistant',
     'Administrator'].include? current_role_name
  end

  def auto_complete_for_user_name
    group = Group.find(session[:group_id])
    @users = group.get_possible_group_members(params[:user][:name])
    render inline: "<%= auto_complete_result @users, 'name' %>", layout: false
  end

  def list
    @group = Group.find(params[:id])
    @assignment = Assignment.find(@group.assignment_id)
    @groups_users = GroupsUser.page(params[:page]).per_page(10).where(["group_id = ?", params[:id]])
  end

  def new
    @group = Group.find(params[:id])
  end

  def create
    user = User.find_by_name(params[:user][:name].strip)
    unless user
      urlCreate = url_for controller: 'users', action: 'new'
      flash[:error] = "\"#{params[:user][:name].strip}\" is not defined. Please <a href=\"#{urlCreate}\">create</a> this user before continuing."
    end

    group = Group.find(params[:id])

    if group.is_a?(AssignmentGroup)
      assignment = Assignment.find(group.parent_id)
      if AssignmentParticipant.find_by_user_id_and_assignment_id(user.id, assignment.id).nil?
        urlAssignmentParticipantList = url_for controller: 'participants', action: 'list', id: assignment.id, model: 'Assignment', authorization: 'participant'
        flash[:error] = "\"#{user.name}\" is not a participant of the current assignment. Please <a href=\"#{urlAssignmentParticipantList}\">add</a> this user before continuing."
      else
        add_member_return = group.add_member(user, group.parent_id)
        if add_member_return == false
          flash[:error] = "This group already has the maximum number of members."
        end

        @groups_user = GroupsUser.last
        undo_link("The group user \"#{user.name}\" has been successfully added to \"#{group.name}\".")
      end
    else #CourseTeam
      course = Course.find(group.parent_id)
      if CourseParticipant.find_by_user_id_and_parent_id(user.id, course.id).nil?
        urlCourseParticipantList = url_for controller: 'participants', action: 'list', id: course.id, model: 'Course', authorization: 'participant'
        flash[:error] = "\"#{user.name}\" is not a participant of the current course. Please <a href=\"#{urlCourseParticipantList}\">add</a> this user before continuing."
      else
        add_member_return = group.add_member(user)
        if add_member_return == false
          flash[:error] = "This group already has the maximum number of members."
        end

        @groups_user = GroupsUser.last
        undo_link("The group user \"#{user.name}\" has been successfully added to \"#{group.name}\".")
      end
    end

    redirect_to controller: 'groups', action: 'list', id: group.parent_id
  end

  def delete
    @groups_user = GroupsUser.find(params[:id])
    parent_id = Group.find(@groups_user.group_id).parent_id
    @user = User.find(@groups_user.user_id)
    @groups_user.destroy
    undo_link("The group user \"#{@user.name}\" has been successfully removed. ")
    redirect_to controller: 'groups', action: 'list', id: parent_id
  end

  def delete_selected
    params[:item].each do |item_id|
      group_user = GroupsUser.find(item_id).first
      group_user.destroy
    end

    redirect_to action: 'list', id: params[:id]
  end
end
