class TeamsUsersController < ApplicationController
  include AuthorizationHelper

  def action_allowed?
    # Allow duty updation for a team if current user is student, else require TA or above Privileges.
    if %w[update_duties].include? params[:action]
      current_user_has_student_privileges?
    else
      current_user_has_ta_privileges?
    end
  end

  def auto_complete_for_user_name
    team = Team.find(session[:team_id])
    @users = team.get_possible_team_members(params[:user][:username])
    render inline: "<%= auto_complete_result @users, 'username' %>", layout: false
  end

  # Example of duties: manager, designer, programmer, tester. Finds TeamsUser and save preferred Duty
  def update_duties
    team_user = TeamsUser.find(params[:teams_user_id])
    team_user.update_attribute(:duty_id, params[:teams_user]['duty_id'])
    redirect_to controller: 'student_teams', action: 'view', student_id: params[:participant_id]
  end

  def list
    @team = Team.find(params[:id])
    @assignment = Assignment.find(@team.parent_id)
    @teams_users = TeamsUser.page(params[:page]).per_page(10).where(['team_id = ?', params[:id]])
  end

  def new
    @team = Team.find(params[:id])
  end

  def create
    user = User.find_by(username: params[:user][:username].strip)
    unless user
      urlCreate = url_for controller: 'users', action: 'new'
      flash[:error] = "\"#{params[:user][:username].strip}\" is not defined. Please <a href=\"#{urlCreate}\">create</a> this user before continuing."
    end

    team = Team.find(params[:id])
    unless user.nil?
      if team.is_a?(AssignmentTeam)
        assignment = Assignment.find(team.parent_id)
        if assignment.user_on_team?(user)
          flash[:error] = "This user is already assigned to a team for this assignment"
          redirect_back fallback_location: root_path
          return
        end
        if AssignmentParticipant.find_by(user_id: user.id, parent_id: assignment.id).nil?
          urlAssignmentParticipantList = url_for controller: 'participants', action: 'list', id: assignment.id, model: 'Assignment', authorization: 'participant'
          flash[:error] = "\"#{user.username}\" is not a participant of the current assignment. Please <a href=\"#{urlAssignmentParticipantList}\">add</a> this user before continuing."
        else
          begin
            add_member_return = team.add_member(user, team.parent_id)
          rescue
            flash[:error] = "The user #{user.username} is already a member of the team #{team.name}"
            redirect_back fallback_location: root_path
            return
          end
          flash[:error] = 'This team already has the maximum number of members.' if add_member_return == false
        end
      else # CourseTeam
        course = Course.find(team.parent_id)
        if course.user_on_team?(user)
          flash[:error] = "This user is already assigned to a team for this course"
          redirect_back fallback_location: root_path
          return
        end
        if CourseParticipant.find_by(user_id: user.id, parent_id: course.id).nil?
          urlCourseParticipantList = url_for controller: 'participants', action: 'list', id: course.id, model: 'Course', authorization: 'participant'
          flash[:error] = "\"#{user.username}\" is not a participant of the current course. Please <a href=\"#{urlCourseParticipantList}\">add</a> this user before continuing."
        else
          begin
            add_member_return = team.add_member(user, team.parent_id)
          rescue
            flash[:error] = "The user #{user.username} is already a member of the team #{team.name}"
            redirect_back fallback_location: root_path
            return
          end
          flash[:error] = 'This team already has the maximum number of members.' if add_member_return == false
          if add_member_return
            @teams_user = TeamsUser.last
            undo_link("The team user \"#{user.username}\" has been successfully added to \"#{team.name}\".")
          end
        end
      end
    end

    redirect_to controller: 'teams', action: 'list', id: team.parent_id
  end

  def delete
    @teams_user = TeamsUser.find(params[:id])
    parent_id = Team.find(@teams_user.team_id).parent_id
    @user = User.find(@teams_user.user_id)
    @teams_user.destroy
    undo_link("The team user \"#{@user.username}\" has been successfully removed. ")
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
