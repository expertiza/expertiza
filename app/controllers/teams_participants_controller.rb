class TeamsParticipantController < ApplicationController
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
  rescue ActiveRecord::RecordNotFound => e
    flash[:error] = "Team not found: #{e.message}"
    redirect_back fallback_location: root_path
  end

  def update_duties
    team_participant = TeamsParticipant.find(params[:teams_participant_id])
    team_participant.update_attribute(:duty_id, params[:teams_participant]['duty_id'])
    redirect_to controller: 'student_teams', action: 'view', student_id: params[:participant_id]
  rescue ActiveRecord::RecordNotFound => e
    flash[:error] = "Team participant not found: #{e.message}"
    redirect_back fallback_location: root_path
  rescue ActiveRecord::RecordInvalid => e
    flash[:error] = "Failed to update duty: #{e.message}"
    redirect_back fallback_location: root_path
  end

  def list
    @team = Team.find(params[:id])
    @assignment = Assignment.find(@team.parent_id)
    @teams_participants = TeamsParticipant.page(params[:page]).per_page(10).where(['team_id = ?', params[:id]])
  rescue ActiveRecord::RecordNotFound => e
    flash[:error] = "Team or assignment not found: #{e.message}"
    redirect_back fallback_location: root_path
  end

  def new
    @team = Team.find(params[:id])
  rescue ActiveRecord::RecordNotFound => e
    flash[:error] = "Team not found: #{e.message}"
    redirect_back fallback_location: root_path
  end

  def create
    user = User.find_by(name: params[:user][:name].strip)
    unless user
      urlCreate = url_for controller: 'users', action: 'new'
      flash[:error] = "\"#{params[:user][:name].strip}\" is not defined. Please <a href=\"#{urlCreate}\">create</a> this user before continuing."
      redirect_back fallback_location: root_path
      return
    end

    team = Team.find(params[:id])
    add_team_member(team, user)
  rescue ActiveRecord::RecordNotFound => e
    flash[:error] = "Team not found: #{e.message}"
    redirect_back fallback_location: root_path
  end

  def delete
    return unless validate_delete_params

    team_participant = TeamsParticipant.find(params[:id])
    parent_id = Team.find(team_participant.team_id).parent_id
    participant = Participant.find(team_participant.participant_id)
    
    team_participant.destroy
    undo_link("The team participant \"#{participant.name}\" has been successfully removed.")
    redirect_to controller: 'teams', action: 'list', id: parent_id
  rescue ActiveRecord::RecordNotFound => e
    flash[:error] = "Record not found: #{e.message}"
    redirect_back fallback_location: root_path
  end

  def delete_selected
    return unless validate_delete_selected_params

    params[:item].each do |item_id|
      team_participant = TeamsParticipant.find(item_id)
      team_participant.destroy
    end

    redirect_to action: 'list', id: params[:id]
  rescue ActiveRecord::RecordNotFound => e
    flash[:error] = "One or more team participants not found: #{e.message}"
    redirect_back fallback_location: root_path
  end

  private

  def validate_delete_params
    unless params[:id].present?
      flash[:error] = "No team participant ID provided"
      redirect_back fallback_location: root_path
      return false
    end
    true
  end

  def validate_delete_selected_params
    unless params[:item].present? && params[:item].is_a?(Array) && !params[:item].empty?
      flash[:error] = "No team participants selected for deletion"
      redirect_back fallback_location: root_path
      return false
    end
    true
  end

  def add_team_member(team, user)
    if team.is_a?(AssignmentTeam)
      add_assignment_team_member(team, user)
    else
      add_course_team_member(team, user)
    end
  end

  def add_assignment_team_member(team, user)
    assignment = Assignment.find(team.parent_id)
    if assignment.user_on_team?(user)
      flash[:error] = "This user is already assigned to a team for this assignment"
      redirect_back fallback_location: root_path
      return
    end

    participant = AssignmentParticipant.find_by(user_id: user.id, parent_id: assignment.id)
    if participant.nil?
      urlAssignmentParticipantList = url_for controller: 'participants', action: 'list', id: assignment.id, model: 'Assignment', authorization: 'participant'
      flash[:error] = "\"#{user.name}\" is not a participant of the current assignment. Please <a href=\"#{urlAssignmentParticipantList}\">add</a> this user before continuing."
      redirect_back fallback_location: root_path
      return
    end

    add_member_to_team(team, participant)
  end

  def add_course_team_member(team, user)
    course = Course.find(team.parent_id)
    if course.user_on_team?(user)
      flash[:error] = "This user is already assigned to a team for this course"
      redirect_back fallback_location: root_path
      return
    end

    participant = CourseParticipant.find_by(user_id: user.id, parent_id: course.id)
    if participant.nil?
      urlCourseParticipantList = url_for controller: 'participants', action: 'list', id: course.id, model: 'Course', authorization: 'participant'
      flash[:error] = "\"#{user.name}\" is not a participant of the current course. Please <a href=\"#{urlCourseParticipantList}\">add</a> this user before continuing."
      redirect_back fallback_location: root_path
      return
    end

    add_member_to_team(team, participant)
  end

  def add_member_to_team(team, participant)
    begin
      add_member_return = team.add_member(participant, team.parent_id)
      if add_member_return
        @teams_participant = TeamsParticipant.last
        undo_link("The team participant \"#{participant.name}\" has been successfully added to \"#{team.name}\".")
      else
        flash[:error] = 'This team already has the maximum number of members.'
      end
    rescue ActiveRecord::RecordInvalid => e
      flash[:error] = "The participant #{participant.name} is already a member of the team #{team.name}"
      redirect_back fallback_location: root_path
      return
    end

    redirect_to controller: 'teams', action: 'list', id: team.parent_id
  end
end 