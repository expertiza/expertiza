class InvitationController < ApplicationController
  @@messages = Hash.new
  
  def action_allowed?
    ['Student', 'Instructor', 'Teaching Assistant'].include?(current_role_name)
  end

  def new
    @invitation = Invitation.new
  end
  def create

    
    user = User.find_by_name(params[:user][:name].strip)
    team = AssignmentTeam.find(params[:team_id])
    student = AssignmentParticipant.find(params[:student_id])
    username = params[:user][:name].strip
    
    #Used to set the flash messages displayed to the user

    set_messages(username)
    
    return unless current_user_id?(student.user_id)
    
    #Check if the invited user is valid
    
    if user.nil?
      flash[:note] = @@messages[:user_not_found];
    else
      participant= AssignmentParticipant.where('user_id =? and parent_id =?', user.id, student.parent_id).first
      #Check if the user is a participant of the assignment
      if participant.nil?
        flash[:note] = @@messages[:user_not_participant];
      elsif team.full?
         flash[:error] = @@messages[:max_members];
      else
        team_member = TeamsUser.where(['team_id =? and user_id =?', team.id, user.id])
        #Check if invited user is already in the team
        unless team_member.empty?
          flash[:note] = @@messages[:already_member]
        else
          #Check if the invited user is already invited (i.e. awaiting reply)
          if Invitation.is_invited?(student.user_id, user.id, student.parent_id)
            set_invitation(user.id,student.user_id,student.parent_id,'W')
          else
            flash[:note] = @@messages[:already_invited]
          end
        end
      end
    end
    update_join_team_request user,student
    redirect_to view_student_teams_path student_id: student.id
  end

  def update_join_team_request(user,student)
    #update the status in the join_team_request to A
    if user && student
      participant= AssignmentParticipant.where(['user_id =? and parent_id =?', user.id, student.parent_id]).first
      if participant
        old_entry = JoinTeamRequest.where(['participant_id =? and team_id =?', participant.id,params[:team_id]]).first
        if old_entry
          old_entry.update_attribute("status",'A')
        end
      end
    end
  end

  def auto_complete_for_user_name
    search = params[:user][:name].to_s
    @users = User.find_by_sql("select * from users where LOWER(name) LIKE '%"+search+"%'") unless search.blank?
  end

  def accept
    @inv = Invitation.find(params[:inv_id])
    student = Participant.find(params[:student_id])
    assignment_id=@inv.assignment_id
    inviter_user_id=@inv.from_id

    inviter_participant = AssignmentParticipant.find_by_user_id_and_assignment_id(inviter_user_id,assignment_id)

    ready_to_join=false
    #check if the inviter's team is still existing, and have available slot to add the invitee
    inviter_assignment_team = AssignmentTeam.team(inviter_participant)
    if inviter_assignment_team.nil?
      flash[:error]= @@messages[:invitation_not_exist]
    else
      if inviter_assignment_team.full?
        flash[:error]= @@messages[:full_team]
      else
        ready_to_join=true
      end
    end

    if ready_to_join
      @inv.reply_status = 'A'
      @inv.save

      #Remove the users previous team since they are accepting an invite for possibly a new team.
      TeamsUser.remove_team(student.user_id, params[:team_id])

      #Accept the invite and return boolean on whether the add was successful
      add_successful = Invitation.accept_invite(params[:team_id], @inv.from_id, @inv.to_id, student.parent_id)

      unless add_successful
        flash[:error] = @@messages[:fail_to_add]
      end
    else
      #The error message should have been flashed from the checks on ready_to_join flag
    end

    redirect_to view_student_teams_path student_id: params[:student_id]

  end

  def decline
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

  private def set_messages(name)
    @@messages[:user_not_found] = "\"#{name}\" does not exist. Please make sure the name entered is correct."
    @@messages[:user_not_participant] = "\"#{name}\" is not a participant of this assignment."
    @@messages[:max_members] = "Your team already has max members."
    @@messages[:already_member] = "\"#{name}\" is already a member of team."
    @@messages[:already_invited] = "You have already sent an invitation to \"#{name}\"."
    @@messages[:full_team] = "The team which invited you is full now."
    @@messages[:invitation_not_exist]= "The team which invited you does not exist any more."
    @@messages[:fail_to_add] = "The system fails to add you to the team which invited you."
  end
  private def set_invitation(to_id,from_id,assignment_id,reply_status)
    @invitation = Invitation.new
    @invitation.to_id = to_id
    @invitation.from_id = from_id
    @invitation.assignment_id = assignment_id
    @invitation.reply_status = reply_status
    @invitation.save
  end
end
