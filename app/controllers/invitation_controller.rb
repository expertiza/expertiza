class InvitationController < ApplicationController
  def action_allowed?
    ['Instructor', 'Teaching Assistant', 'Administrator', 'Super-Administrator', 'Student'].include? current_role_name
  end

  def new
    @invitation = Invitation.new
  end

  def create

    user = User.find_by_name(params[:user][:name].strip)
    team = AssignmentTeam.find(params[:team_id])
    student = AssignmentParticipant.find(params[:student_id])
    return unless current_user_id?(student.user_id)

    # check if the invited user is valid
    if !user
      flash[:note] = "The user \"#{params[:user][:name].strip}\" does not exist. Please make sure the name entered is correct."
    else
      participant = AssignmentParticipant.where('user_id =? and parent_id =?', user.id, student.parent_id).first
      # check if the user is a participant of the assignment
      if !participant
        flash[:note] = "The user \"#{params[:user][:name].strip}\" is not a participant of this assignment."
      elsif team.full?
        flash[:error] = "Your team already has the maximum number members."
      else
        team_member = TeamsUser.where(['team_id =? and user_id =?', team.id, user.id])
        # check if invited user is already in the team
        if !team_member.empty?
          flash[:note] = "The user \"#{user.name}\" is already a member of the team."
        else
          # check if the invited user is already invited (i.e. awaiting reply)
          if Invitation.is_invited?(student.user_id, user.id, student.parent_id)
            @invitation = Invitation.new
            @invitation.to_id = user.id
            @invitation.from_id = student.user_id
            @invitation.assignment_id = student.parent_id
            @invitation.reply_status = 'W'
            @invitation.save

            @@event_logger.warn "&invitation_controller|Invite|#{session[:user].role_id}|#{session[:user].id}|Invitation Created"
          else
            flash[:note] = "You have already sent an invitation to \"#{user.name}\"."
          end
        end
      end
    end

    update_join_team_request user, student

    redirect_to view_student_teams_path student_id: student.id
  end

  def update_join_team_request(user, student)
    # update the status in the join_team_request to A
    if user && student
      participant = AssignmentParticipant.where(['user_id =? and parent_id =?', user.id, student.parent_id]).first
      if participant
        old_entry = JoinTeamRequest.where(['participant_id =? and team_id =?', participant.id, params[:team_id]]).first
        old_entry.update_attribute("status", 'A') if old_entry
      end
    end
  end

  def auto_complete_for_user_name
    search = params[:user][:name].to_s
    @users = User.where("LOWER(name) LIKE ?", "%#{search}%") unless search.blank?
  end

  def accept
    @@event_logger.warn "&invitation_controller|Accept|#{session[:user].role_id}|#{session[:user].id}|Invitation Accepted"
    @inv = Invitation.find(params[:inv_id])

    student = Participant.find(params[:student_id])

    assignment_id = @inv.assignment_id
    inviter_user_id = @inv.from_id
    inviter_participant = AssignmentParticipant.find_by_user_id_and_assignment_id(inviter_user_id, assignment_id)

    ready_to_join = false
    # check if the inviter's team is still existing, and have available slot to add the invitee
    inviter_assignment_team = AssignmentTeam.team(inviter_participant)
    if inviter_assignment_team.nil?
      flash[:error] = "The team that invited you does not exist anymore."
    else
      if inviter_assignment_team.full?
        flash[:error] = "The team that invited you is full now."
      else
        ready_to_join = true
      end
    end

    if ready_to_join
      @inv.reply_status = 'A'
      @inv.save

      # Remove the users previous team since they are accepting an invite for possibly a new team.
      TeamsUser.remove_team(student.user_id, params[:team_id])

      # Accept the invite and return boolean on whether the add was successful
      add_successful = Invitation.accept_invite(params[:team_id], @inv.from_id, @inv.to_id, student.parent_id)

      unless add_successful
        flash[:error] = "The system failed to add you to the team that invited you."
      end
    end

    redirect_to view_student_teams_path student_id: params[:student_id]
  end

  def decline
    @@event_logger.warn "&invitation_controller|Decline|#{session[:user].role_id}|#{session[:user].id}|Invitation Declined"
    @inv = Invitation.find(params[:inv_id])
    @inv.reply_status = 'D'
    @inv.save
    student = Participant.find(params[:student_id])
    redirect_to view_student_teams_path student_id: student.id
  end

  def cancel
    Invitation.find(params[:inv_id]).destroy
    redirect_to view_student_teams_path student_id: params[:student_id]
  end
end
