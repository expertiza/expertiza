class InvitationController < ApplicationController
  def new 
    @invitation = Invitation.new
  end
  
  def create    
    user = User.find_by_name(params[:user][:name].strip)
    team = AssignmentTeam.find_by_id(params[:team_id])
    student = AssignmentParticipant.find(params[:student_id])
    #check if the invited user is valid
    if !user
      flash[:notice] = "\"#{params[:user][:name].strip}\" does not exist. Please make sure the name entered is correct." 
    else
      participant = AssignmentParticipant.find(:first, :conditions => ['user_id =? and parent_id =?', user.id, student.parent_id])
      if !participant
        flash[:notice] = "\"#{params[:user][:name].strip}\" is not a participant of this assignment." 
      else
        check = TeamsUser.find(:all, :conditions => ['team_id =? and user_id =?', team.id, user.id])
        #check if invited user is already in the team
        if (check.size > 0)
          flash[:notice] = "\"#{user.name}\" is already a member of team."
        else
          current_invs = Invitation.find(:all, :conditions => ['from_id = ? and to_id = ? and assignment_id = ? and reply_status = "W"', student.user_id, user.id, student.parent_id])
          #check if the invited user is already invited (i.e. awaiting reply)
          if current_invs.length == 0
            @invitation = Invitation.new
            @invitation.to_id = user.id
            @invitation.from_id = student.user_id
            @invitation.assignment_id = student.parent_id
            @invitation.reply_status = 'W' 
            @invitation.save
          else
            flash[:notice] = "You have already send an invitation to \"#{user.name}\"."  
          end   
        end
      end
    end
    redirect_to :controller => 'student_assignment', :action => 'view_team', :id=> student.id
  end
  
  def auto_complete_for_user_name
    search = params[:user][:name].to_s
    @users = User.find_by_sql("select * from users where LOWER(name) LIKE '%"+search+"%'") unless search.blank?    
  end
 
  def accept
    @inv = Invitation.find(params[:inv_id])
    @inv.reply_status = 'A'
    @inv.update
    
    student = Participant.find(params[:student_id])
    
    #if you are on a team and you accept another invitation, remove your previous entry
    old_entry = TeamsUser.find(:first, :conditions => ['user_id = ? and team_id = ?', student.user_id, params[:team_id]])
    if old_entry != nil
      old_entry.destroy
    end
    
    #if you are on a team and you accept another invitation and if your old team does not have any members, delete the entry for the team
    other_members = TeamsUser.find(:all, :conditions => ['team_id = ?', params[:team_id]])
    if other_members.length == 0
      old_team = AssignmentTeam.find(:first, :conditions => ['id = ?', params[:team_id]])
      if old_team != nil
        old_team.destroy
      end
    end
    
    #if you change your team, remove all your invitations that you send to other people
    old_invs = Invitation.find(:all, :conditions => ['from_id = ? and assignment_id = ?', @inv.to_id, student.parent_id])
    for old_inv in old_invs
      old_inv.destroy
    end
    
    #create a new team_user entry for the accepted invitation
    @team_user = TeamsUser.new
    users_teams = TeamsUser.find(:all, :conditions => ['user_id = ?', @inv.from_id])
    for team in users_teams
      current_team = AssignmentTeam.find(:first, :conditions => ['id = ? and parent_id = ?', team.team_id, student.parent_id])
      if current_team != nil
        @team_user.team_id = current_team.id
      end
    end
    @team_user.user_id = @inv.to_id
    @team_user.save
    
    redirect_to :controller => 'student_assignment', :action => 'view_team', :id => student.id
  end
  
  def decline
    @inv = Invitation.find(params[:inv_id])
    @inv.reply_status = 'D'
    @inv.update
    student = Participant.find(params[:student_id])
    redirect_to :controller => 'student_assignment', :action => 'view_team' , :id => student.id
  end

  def cancel
    Invitation.find(params[:inv_id]).destroy
    redirect_to :controller => 'student_assignment', :action => 'view_team' , :id => params[:student_id]
  end

end