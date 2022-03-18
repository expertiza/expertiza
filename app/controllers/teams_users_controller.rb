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
    @users = team.get_possible_team_members(params[:user][:name])
    render inline: "<%= auto_complete_result @users, 'name' %>", layout: false
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

  def flash_error(message, values = nil)
    flash[:error] = values ? message % values : message
  end
  def addTeamMember(team,user,msg)
    begin
      add_member_return = team.add_member(user, team.parent_id)
    rescue
      flash_error("The user #{user.name} is already a member of the team #{team.name}")
      redirect_back
      return
    end
    flash_error('This team already has the maximum number of members.') if add_member_return == false
    if add_member_return
      user = TeamsUser.last
      undo_link("The team @teams_user \"#{user.name}\" has been successfully added to \"#{team.name}\".")
      if msg=="assignment"
        MentorManagement.assign_mentor(assignment.id, team.id)
      end
    end
  end


  def isUserAssigned(model,user)
    if model.user_on_team?(user)
      flash_error(msg)
      redirect_back
      return
    end
  end

  def isParticipant(modelParticipant,user,primaryAssignment,team,msg,msg1)
    if modelParticipant.find_by(user_id: user.id, parent_id: primaryAssignment.id).nil?
      urlAssignmentParticipantList = msg
      flash_error("\"#{user.name}\" is not a participant of the current#{msg1} . Please <a href=\"#{urlAssignmentParticipantList}\">add</a> this user before continuing.")
    else
      addMemberReturn(team,user,msg1)
    end
  end

  


  def usrUrl(user,stripped_name)
    unless user
      flash_error(%[“%s” is not defined. Please <a href=”%s”>create this user</a>
        before continuing.], [stripped_name, new_user_path])
    end
  end


def modelAssignment(model,team,user,msg,modelParticipant)
    assignment = model.find(team.parent_id)
    isUserAssigned(assignment,user,"This user is already assigned to a team for this " + msg)
    urlAssignmentParticipantList=""
    if msg=="course"
      urlCourseParticipantList = url_for controller: 'participants', action: 'list', id: course.id, model: 'Course', authorization: 'participant'
    else
      urlAssignmentParticipantList=url_for controller: 'participants', action: 'list', id: assignment.id, model: 'Assignment', authorization: 'participant'
    end
    isParticipant(modelParticipant,user,assignment,team,urlAssignmentParticipantList, msg)
  end
    
  def create
    stripped_name = params[:user][:name].strip
    user = User.find_by(name: stripped_name)
    usrUrl(user,stripped_name)
    team = Team.find(params[:id])
    unless user.nil?
      if team.is_a?(AssignmentTeam)
        modelAssignment(Assignment,team,user,"assignment",AssignmentParticipant)
      else 
        modelAssignment(Course,team,user,"course",CourseParticipant)
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
