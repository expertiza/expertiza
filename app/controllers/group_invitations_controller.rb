class GroupInvitationsController < ApplicationController
  def action_allowed?
    ['Instructor', 'Teaching Assistant', 'Administrator', 'Super-Administrator', 'Student'].include? current_role_name
  end
  # GET /group_invitations
  def index
    @group_invitations = GroupInvitation.new
  end

  # POST /group_invitations
  def create
    user = User.find_by_name(params[:user][:name].strip)
    group = Group.find(params[:group_id])
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
      elsif group.full?
        flash[:error] = "Your group already has the maximum number members."
      else
        group_member = GroupsUser.where(['group_id =? and user_id =?', group.id, user.id])
        # check if invited user is already in the group
        if !group_member.empty?
          flash[:note] = "The user \"#{user.name}\" is already a member of the group."
        else
          # check if the invited user is already invited (i.e. awaiting reply)
          if GroupInvitation.is_invited?(student.user_id, user.id, student.parent_id)
            @group_invitation = GroupInvitation.new
            @group_invitation.to_id = user.id
            @group_invitation.from_id = student.user_id
            @group_invitation.assignment_id = student.parent_id
            @group_invitation.reply_status = 'W'
            @group_invitation.save
          else
            flash[:note] = "You have already sent an invitation to \"#{user.name}\"."
          end
        end
      end
    end

    update_join_group_request user, student

    redirect_to view_student_groups_path student_id: student.id
  end

  # PATCH/PUT /group_invitations/1
  def update_join_group_request(user, student)
    # update the status in the join_group_request to A
    if user && student
      participant = AssignmentParticipant.where(['user_id =? and parent_id =?', user.id, student.parent_id]).first
      if participant
        old_entry = JoinGroupRequest.where(['participant_id =? and group_id =?', participant.id, params[:group_id]]).first
        old_entry.update_attribute("status", 'A') if old_entry
      end
    end
  end

  def auto_complete_for_user_name
    search = params[:user][:name].to_s
    @users = User.where("LOWER(name) LIKE ?", "%#{search}%") unless search.blank?
  end

  def accept
    @inv = GroupInvitation.find(params[:inv_id])

    student = Participant.find(params[:student_id])

    assignment_id = @inv.assignment_id
    inviter_user_id = @inv.from_id
    inviter_participant = AssignmentParticipant.find_by_user_id_and_assignment_id(inviter_user_id, assignment_id)

    ready_to_join = false
    # check if the inviter's group is still existing, and have available slot to add the invitee
    inviter_assignment_group = Group.group(inviter_participant)
    if inviter_assignment_group.nil?
      flash[:error] = "The group that invited you does not exist anymore."
    else
      if inviter_assignment_group.full?
        flash[:error] = "The group that invited you is full now."
      else
        ready_to_join = true
      end
    end

    if ready_to_join
      @inv.reply_status = 'A'
      @inv.save

      # Remove the users previous group since they are accepting an invite for possibly a new group.
      GroupsUser.remove_group(student.user_id, params[:group_id])

      # Accept the invite and return boolean on whether the add was successful
      add_successful = GroupInvitation.accept_invite(params[:group_id], @inv.from_id, @inv.to_id, student.parent_id)

      unless add_successful
        flash[:error] = "The system failed to add you to the group that invited you."
      end
    end

    redirect_to view_student_groups_path student_id: params[:student_id]
  end

  def decline
    @inv = GroupInvitation.find(params[:inv_id])
    @inv.reply_status = 'D'
    @inv.save
    student = Participant.find(params[:student_id])
    redirect_to view_student_groups_path student_id: student.id
  end

  def cancel
    GroupInvitation.find(params[:inv_id]).destroy
    redirect_to view_student_groups_path student_id: params[:student_id]
  end
end
