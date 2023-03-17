class StudentTeamsController < ApplicationController
  include AuthorizationHelper

  autocomplete :user, :name

  def team
    @team ||= AssignmentTeam.find params[:team_id]
  end

  attr_writer :team

  def student
    @student ||= AssignmentParticipant.find(params[:student_id])
  end

  attr_writer :student

  before_action :team, only: %i[edit update]
  before_action :student, only: %i[view update edit create remove_participant]

  def action_allowed?
    # note, this code replaces the following line that cannot be called before action allowed?
    return false unless current_user_has_student_privileges?

    case action_name
    when 'view'
      if are_needed_authorizations_present?(params[:student_id], 'reader', 'reviewer', 'submitter')
        return true if current_user_has_id? student.user_id
      else
        return false
      end
    when 'create'
      current_user_has_id? student.user_id
    when 'edit', 'update'
      current_user_has_id? team.user_id
    else
      true
    end
  end

  def controller_locale
    locale_for_student
  end

  def view
    # View will check if send_invs and received_invs are set before showing
    # only the owner should be able to see those.

    return unless current_user_id? student.user_id

    @send_invs = Invitation.where from_id: student.user.id, assignment_id: student.assignment.id
    @received_invs = Invitation.where to_id: student.user.id, assignment_id: student.assignment.id, reply_status: 'W'

    @current_due_date = DueDate.current_due_date(@student.assignment.due_dates)

    # this line generates a list of users on the waiting list for the topic of a student's team,
    @users_on_waiting_list = (SignUpTopic.find(@student.team.topic).users_on_waiting_list if student_team_requirements_met?)
    @teammate_review_allowed = DueDate.teammate_review_allowed(@student)
  end

  def create
    existing_teams = AssignmentTeam.where name: params[:team][:name], parent_id: student.parent_id
    # check if the team name is in use
    if existing_teams.empty?
      if params[:team][:name].blank?
        flash[:notice] = 'The team name is empty.'
        ExpertizaLogger.info LoggerMessage.new(controller_name, session[:user].name, 'Team name missing while creating team', request)
        redirect_to view_student_teams_path student_id: student.id
        return
      end
      team = AssignmentTeam.new(name: params[:team][:name], parent_id: student.parent_id)
      team.save
      parent = AssignmentNode.find_by node_object_id: student.parent_id
      TeamNode.create parent_id: parent.id, node_object_id: team.id
      user = User.find(student.user_id)
      team.add_member(user, team.parent_id)
      team_created_successfully(team)
      redirect_to view_student_teams_path student_id: student.id

    else
      flash[:notice] = 'That team name is already in use.'
      ExpertizaLogger.error LoggerMessage.new(controller_name, session[:user].name, 'Team name being created was already in use', request)
      redirect_to view_student_teams_path student_id: student.id
    end
  end

  def edit; end

  def update
    # Update the team name only if the given team name is not used already
    matching_teams = AssignmentTeam.where name: params[:team][:name], parent_id: team.parent_id
    if matching_teams.length.zero?
      if team.update_attribute('name', params[:team][:name])
        team_created_successfully
        redirect_to view_student_teams_path student_id: params[:student_id]
      end
    elsif matching_teams.length == 1 && matching_teams.name == team.name
      team_created_successfully
      redirect_to view_student_teams_path student_id: params[:student_id]
    else
      flash[:notice] = 'That team name is already in use.'
      ExpertizaLogger.info LoggerMessage.new(controller_name, session[:user].name, 'Team name being updated to was already in use', request)
      redirect_to view_student_teams_path student_id: params[:student_id]

    end
  end

  def remove_participant
    # remove the record from teams_users table
    team_user = TeamsUser.where(team_id: params[:team_id], user_id: student.user_id)
    remove_team_user(team_user)
    # if your old team does not have any members, delete the entry for the team
    if TeamsUser.where(team_id: params[:team_id]).empty?
      old_team = AssignmentTeam.find params[:team_id]
      if old_team && !old_team.received_any_peer_review?
        old_team.destroy
        # if assignment has signup sheet then the topic selected by the team has to go back to the pool
        # or to the first team in the waitlist
        Waitlist.remove_from_waitlists(params[:team_id])
      end
    end
    # remove all the sent invitations
    old_invites = Invitation.where from_id: student.user_id, assignment_id: student.parent_id
    old_invites.each(&:destroy)
    student.save
    redirect_to view_student_teams_path student_id: student.id
  end

  def remove_team_user(team_user)
    return false unless team_user

    team_user.destroy_all
    undo_link "The user \"#{team_user.name}\" has been successfully removed from the team."
    ExpertizaLogger.info LoggerMessage.new(controller_name, session[:user].name, 'User removed a participant from the team', request)
  end

  def team_created_successfully(current_team = nil)
    if current_team
      undo_link "The team \"#{current_team.name}\" has been successfully updated."
    else
      undo_link "The team \"#{team.name}\" has been successfully updated."
    end
    ExpertizaLogger.info LoggerMessage.new(controller_name, session[:user].name, 'The team has been successfully created.', request)
  end

  # This method is used to show the Author Feedback Questionnaire of current assignment
  def review
    @assignment = Assignment.find params[:assignment_id]
    redirect_to view_questionnaires_path id: @assignment.questionnaires.find_by(type: 'AuthorFeedbackQuestionnaire').id
  end

  # used to check student team requirements
  def student_team_requirements_met?
    # checks if the student has a team
    return false if @student.team.nil?
    # checks that the student's team has a topic
    return false if @student.team.topic.nil?

    # checks that the student has selected some topics
    @student.assignment.topics?
  end
end
