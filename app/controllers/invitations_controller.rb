class InvitationsController < ApplicationController
  include AuthorizationHelper
  include ConferenceHelper

  before_action :check_user_before_invitation, only: [:create]
  before_action :check_team_before_accept, only: [:accept]

  def action_allowed?
    current_user_has_student_privileges?
  end

  def new
    @invitation = Invitation.new
  end

  def create
    # check if the invited user is already invited (i.e. awaiting reply)
    if Invitation.is_invited?(@student.user_id, @user.id, @student.parent_id)
      create_utility
    else
      ExpertizaLogger.error LoggerMessage.new('', @student.name, 'Student was already invited')
      flash[:note] = "You have already sent an invitation to \"#{@user.name}\"."
    end

    update_join_team_request @user, @student

    redirect_to view_student_teams_path student_id: @student.id
  end

  def update_join_team_request(user, student)
    # update the status in the join_team_request to A
    return unless user && student

    # participant information of invitee and assignment
    participant = AssignmentParticipant.where('user_id = ? and parent_id = ?', user.id, student.parent_id).first
    return unless participant

    old_entry = JoinTeamRequest.where('participant_id = ? and team_id = ?', participant.id, params[:team_id]).first
    # Status code A for accepted
    old_entry.update_attribute('status', 'A') if old_entry
  end

  def auto_complete_for_user_name
    search = params[:user][:name].to_s
    @users = User.where('LOWER(name) LIKE ?', "%#{search}%") if search.present?
  end

  def accept
    # Accept the invite and check whether the add was successful
    accepted = Invitation.accept_invitation(params[:team_id], @inv.from_id, @inv.to_id, @student.parent_id)
    flash[:error] = 'The system failed to add you to the team that invited you.' unless accepted

    ExpertizaLogger.info "Accepting Invitation #{params[:inv_id]}: #{accepted}"
    redirect_to view_student_teams_path student_id: params[:student_id]
  end

  def decline
    @inv = Invitation.find(params[:inv_id])
    # Status code D for declined
    @inv.reply_status = 'D'
    @inv.save
    student = Participant.find(params[:student_id])
    ExpertizaLogger.info "Declined invitation #{params[:inv_id]} sent by #{@inv.from_id}"
    redirect_to view_student_teams_path student_id: student.id
  end

  def cancel
    begin
      # Attempt to find and destroy the invitation
      invitation = Invitation.find(params[:inv_id])
      invitation.destroy
  
      # Log the successful cancellation
      ExpertizaLogger.info "Successfully retracted invitation #{params[:inv_id]}"
      flash[:success] = "Invitation successfully retracted."
  
    rescue ActiveRecord::RecordNotFound
      # Log the error and inform the user if the invitation does not exist
      ExpertizaLogger.error "Attempt to retract non-existent invitation #{params[:inv_id]}"
      flash[:error] = "Invitation not found."
  
    rescue => e
      # Handle other potential exceptions and log the detailed error
      ExpertizaLogger.error "Error retracting invitation #{params[:inv_id]}: #{e.message}"
      flash[:error] = "An error occurred while retracting the invitation."
  
    ensure
      # Redirect to the student teams view or another appropriate view
      redirect_to view_student_teams_path(student_id: params[:student_id])
    end
  end
  

  private

  def create_utility
    @invitation = Invitation.new(to_id: @user.id, from_id: @student.user_id)
    @invitation.assignment_id = @student.parent_id
    @invitation.reply_status = 'W'
    @invitation.save
    if @user.email?
      prepared_mail = MailerHelper.send_mail_to_user(@user, 'Invitation Received on Expertiza', 'invite_participant_to_team', '')
      prepared_mail.deliver
    end
    ExpertizaLogger.info LoggerMessage.new(controller_name, @student.name, "Successfully invited student #{@user.id}", request)
  end

  def check_user_before_invitation
    # Extract the user name from the params
    user_name = params[:user_name].strip
    @user = User.find_by(name: user_name)

    # User/Author has information about the participant
    @student = AssignmentParticipant.find_by(id: params[:student_id])
    unless @student
      flash[:error] = "Student not found."
      redirect_to some_fallback_path # Replace with your actual fallback path
      return
    end

    @assignment = Assignment.find_by(id: @student.parent_id)
    unless @assignment
      flash[:error] = "Assignment not found."
      redirect_to some_fallback_path # Replace with your actual fallback path
      return
    end

    @user ||= create_coauthor if @assignment.is_conference_assignment

    return unless current_user_id?(@student.user_id)

    # Check if the invited user is valid
    unless @user
      flash[:error] = "The user \"#{user_name}\" does not exist. Please make sure the name entered is correct."
      redirect_to view_student_teams_path(student_id: @student.id)
      return
    end

    check_participant_before_invitation
  end


  def check_participant_before_invitation
    @participant = AssignmentParticipant.where('user_id = ? and parent_id = ?', @user.id, @student.parent_id).first
    # check if the user is a participant in the assignment
    unless @participant
      if @assignment.is_conference_assignment
        add_participant_coauthor
      else
        flash[:error] = "The user \"#{params[:user][:name].strip}\" is not a participant in this assignment."
        redirect_to view_student_teams_path student_id: @student.id
        return
      end
    end
    check_team_before_invitation
  end

  def check_team_before_invitation
    # team has information about the team
    @team = AssignmentTeam.find(params[:team_id])

    if @team.full?
      flash[:error] = 'Your team already has the maximum number members.'
      redirect_to view_student_teams_path student_id: @student.id
      return
    end

    # participant information about student you are trying to invite to the team
    team_member = TeamsParticipant.where('team_id = ? and user_id = ?', @team.id, @user.id)
    # check if invited user is already in the team

    return if team_member.empty?

    flash[:error] = "The user \"#{@user.name}\" is already a member of the team."
    redirect_to view_student_teams_path student_id: @student.id
  end

  def check_team_before_accept
    @inv = Invitation.find(params[:inv_id])
    # check if the inviter's team is still existing, and have available slot to add the invitee
    inviter_assignment_team = AssignmentTeam.team(AssignmentParticipant.find_by(user_id: @inv.from_id, parent_id: @inv.assignment_id))
    if inviter_assignment_team.nil?
      flash[:error] = 'The team that invited you does not exist anymore.'
      redirect_to view_student_teams_path student_id: params[:student_id]
    elsif inviter_assignment_team.full?
      flash[:error] = 'The team that invited you is full now.'
      redirect_to view_student_teams_path student_id: params[:student_id]
    else
      invitation_accept
    end
  end

  def invitation_accept
    # Status code A for accepted
    @inv.reply_status = 'A'
    @inv.save

    @student = Participant.find(params[:student_id])
    # Remove the users previous team since they are accepting an invite for possibly a new team.
    TeamsParticipant.remove_team(@student.user_id, params[:team_id])
  end
end
