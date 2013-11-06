class InvitationController < ApplicationController
  def new 
    @invitation = Invitation.new
  end

  def create
    user = User.find_by_name(params[:user][:name].strip)
    team = AssignmentTeam.find_by_id(params[:team_id])
    student = AssignmentParticipant.find(params[:student_id])
    return unless current_user_id?(student.user_id)

    #check if the invited user is valid
    if !user
      flash[:note] = "\"#{params[:user][:name].strip}\" does not exist. Please make sure the name entered is correct."
    else
      participant= AssignmentParticipant.first( :conditions => ['user_id =? and parent_id =?', user.id, student.parent_id])
      #check if the user is a participant of the assignment
      if !participant
        flash[:note] = "\"#{params[:user][:name].strip}\" is not a participant of this assignment."
      else
        team_member = TeamsUser.all(:conditions => ['team_id =? and user_id =?', team.id, user.id])
        #check if invited user is already in the team
        if (team_member.size > 0)
          flash[:note] = "\"#{user.name}\" is already a member of team."
        else
          #check if the invited user is already invited (i.e. awaiting reply)
          if Invitation.is_invited?(student.user_id, user.id, student.parent_id)
            @invitation = Invitation.new
            @invitation.to_id = user.id
            @invitation.from_id = student.user_id
            @invitation.assignment_id = student.parent_id
            @invitation.reply_status = 'W'
            @invitation.save
          else
            flash[:note] = "You have already sent an invitation to \"#{user.name}\"."
          end
        end
      end
    end

    update_join_team_request user,student

    redirect_to :controller => 'student_team', :action => 'view', :id=> student.id
  end

  def update_join_team_request(user,student)
    #update the status in the join_team_request to A
    if user && student
      participant= AssignmentParticipant.first( :conditions => ['user_id =? and parent_id =?', user.id, student.parent_id])
      if participant
        old_entry = JoinTeamRequest.first(:conditions => ['participant_id =? and team_id =?', participant.id,params[:team_id]])
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
    @inv.reply_status = 'A'
    @inv.save

    student = Participant.find(params[:student_id])
    
    #Remove the users previous team since they are accepting an invite for possibly a new team.
    TeamsUser.remove_team(student.user_id, params[:team_id])
    #Accept the invite and return boolean on whether the add was successful
    add_successful = Invitation.accept_invite(params[:team_id], @inv.from_id, @inv.to_id, student.parent_id)
    #If add wasn't successful because team was full display message
    unless add_successful
      flash[:error]= "The team already has the maximum number of members."
    end

    redirect_to :controller => 'student_team', :action => 'view', :id => Participant.find(params[:student_id]).id
  end
  
  def decline
    @inv = Invitation.find(params[:inv_id])
    @inv.reply_status = 'D'
    @inv.save
    student = Participant.find(params[:student_id])
    redirect_to :controller => 'student_team', :action => 'view', :id => student.id
  end

  def cancel
    Invitation.find(params[:inv_id]).destroy
    redirect_to :controller => 'student_team', :action => 'view', :id => params[:student_id]
  end

end
