class TeamsUsersController < ApplicationController
  def action_allowed?
    ['Instructor',
     'Teaching Assistant',
     'Administrator'].include? current_role_name
  end

  def auto_complete_for_user_name
    team = Team.find(session[:team_id])
    @users = team.get_possible_team_members(params[:user][:name])
    render inline: "<%= auto_complete_result @users, 'name' %>", layout: false
  end

  def list
    @team = Team.find(params[:id])
    @assignment = Assignment.find(@team.assignment_id)
    @teams_users = TeamsUser.page(params[:page]).per_page(10).where(["team_id = ?", params[:id]])
  end

  def new
    @team = Team.find(params[:id])
  end

  def create
    user = User.find_by_name(params[:user][:name].strip)
    unless user
      urlCreate = url_for controller: 'users', action: 'new'
      flash[:error] = "\"#{params[:user][:name].strip}\" is not defined. Please <a href=\"#{urlCreate}\">create</a> this user before continuing."
    end

    team = Team.find(params[:id])

    if team.is_a?(AssignmentTeam)
      assignment = Assignment.find(team.parent_id)
      if AssignmentParticipant.find_by_user_id_and_assignment_id(user.id, assignment.id).nil?
        urlAssignmentParticipantList = url_for controller: 'participants', action: 'list', id: assignment.id, model: 'Assignment', authorization: 'participant'
        flash[:error] = "\"#{user.name}\" is not a participant of the current assignment. Please <a href=\"#{urlAssignmentParticipantList}\">add</a> this user before continuing."
      else
        add_member_return = team.add_member(user, team.parent_id)
        if add_member_return == false
          flash[:error] = "This team already has the maximum number of members."
        end

        @teams_user = TeamsUser.last
        undo_link("The team user \"#{user.name}\" has been successfully added to \"#{team.name}\".")
      end
    else #CourseTeam
      course = Course.find(team.parent_id)
      if CourseParticipant.find_by_user_id_and_parent_id(user.id, course.id).nil?
        urlCourseParticipantList = url_for controller: 'participants', action: 'list', id: course.id, model: 'Course', authorization: 'participant'
        flash[:error] = "\"#{user.name}\" is not a participant of the current course. Please <a href=\"#{urlCourseParticipantList}\">add</a> this user before continuing."
      else
        add_member_return = team.add_member(user)
        if add_member_return == false
          flash[:error] = "This team already has the maximum number of members."
        end

        @teams_user = TeamsUser.last
        undo_link("The team user \"#{user.name}\" has been successfully added to \"#{team.name}\".")
      end
    end

    redirect_to controller: 'teams', action: 'list', id: team.parent_id
  end

  def delete
    @teams_user = TeamsUser.find(params[:id])
    parent_id = Team.find(@teams_user.team_id).parent_id
    @user = User.find(@teams_user.user_id)
    @teams_user.destroy
    undo_link("The team user \"#{@user.name}\" has been successfully removed. ")
    redirect_to controller: 'teams', action: 'list', id: parent_id
  end

  def delete_selected
    params[:item].each do |item_id|
      team_user = TeamsUser.find(item_id).first
      team_user.destroy
    end

    redirect_to action: 'list', id: params[:id]
  end
end
