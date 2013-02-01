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
      flash[:alert] = "\"#{params[:user][:name].strip}\" does not exist. Please make sure the name entered is correct."
    else
      participant = AssignmentParticipant.find(:first, :conditions => ['user_id =? and parent_id =?', user.id, student.parent_id])
      if !participant
        flash[:alert] = "\"#{params[:user][:name].strip}\" is not a participant of this assignment."
      else
        team_member = TeamsParticipant.find(:all, :conditions => ['team_id =? and user_id =?', team.id, user.id])
        #check if invited user is already in the team
        if (team_member.size > 0)
          flash[:alert] = "\"#{user.name}\" is already a member of team."
        else
          invite=Invitation.find (:all,:conditions => ['from_id=? and to_id=? and assignment_id=? and reply_status="W"', user.id,student.user_id,student.parent_id])
          if (invite.size>0)
            flash[:alert]= " You can’t invite \"#{user.name}\" to join your team, because \"#{user.name}\" has already invited you to join his/her team."
          else

          sent_invitation = Invitation.find(:all, :conditions => ['from_id = ? and to_id = ? and assignment_id = ? and reply_status = "W"', student.user_id, user.id, student.parent_id])
          #check if the invited user is already invited (i.e. awaiting reply)
          if sent_invitation.length == 0
            @invitation = Invitation.new
            @invitation.to_id = user.id
            @invitation.from_id = student.user_id
            @invitation.assignment_id = student.parent_id
            @invitation.reply_status = 'W'
            @invitation.save
          else
            flash[:alert] = "You have already sent an invitation to \"#{user.name}\"."
          end
         end
        end
      end
    end
    redirect_to :controller => 'student_team', :action => 'view', :id=> student.id
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
    
    #if you are on a team and you accept another invitation, remove your previous entry in the teams_participants table.
    old_entry = TeamsParticipant.find(:first, :conditions => ['user_id = ? and team_id = ?', student.user_id, params[:team_id]])
    if old_entry != nil
      old_entry.destroy
    end
    
    #if you are on a team and you accept another invitation and if your old team does not have any members, delete the entry for the team
    other_members = TeamsParticipant.find(:all, :conditions => ['team_id = ?', params[:team_id]])
    if other_members.nil? || other_members.length == 0
      old_team = AssignmentTeam.find(:first, :conditions => ['id = ?', params[:team_id]])
      if old_team != nil
        old_team.destroy
      end

      #if a signup sheet exists then release all the topics selected by this team into the pool.
      old_teams_signups = SignedUpUser.find_all_by_creator_id(params[:team_id])
      if !old_teams_signups.nil?
        for old_teams_signup in old_teams_signups
          if old_teams_signup.is_waitlisted == false # i.e., if the old team was occupying a slot, & thus is releasing a slot ...
            first_waitlisted_signup = SignedUpUser.find_by_topic_id_and_is_waitlisted(old_teams_signup.topic_id, true)
            if !first_waitlisted_signup.nil?
              #As this user is going to be allocated a confirmed topic, all of his waitlisted topic signups should be purged
              first_waitlisted_signup.is_waitlisted = false
              first_waitlisted_signup.save

              #Also update the participant table. But first_waitlisted_signup.creator_id is the team id
              #so find one of the users on the team because the update_topic_id function in participant
              #will take care of updating all the participants on the team
              user_id = TeamsParticipant.find(:first, :conditions => {:team_id => first_waitlisted_signup.creator_id}).user_id
              participant = Participant.find_by_user_id_and_parent_id(user_id,old_team.assignment.id)
              participant.update_topic_id(old_teams_signup.topic_id)
               
              SignUpTopic.cancel_all_waitlists(first_waitlisted_signup.creator_id, SignUpTopic.find(old_teams_signup.topic_id)['assignment_id'])
            end # if !first_waitlisted_signup.nil
            # Remove the now-empty team from the slot it is occupying.
          end # if old_teams_signup.is_waitlisted == false
          old_teams_signup.destroy
        end
      end
    end
    
    #if you change your team, remove all your invitations that you send to other people
    old_invs = Invitation.find(:all, :conditions => ['from_id = ? and assignment_id = ?', @inv.to_id, student.parent_id])
    for old_inv in old_invs
      old_inv.destroy
    end
    
    #create a new team_user entry for the accepted invitation
    @team_user = TeamsParticipant.new
    users_teams = TeamsParticipant.find(:all, :conditions => ['user_id = ?', @inv.from_id])
    for team in users_teams
      current_team = AssignmentTeam.find(:first, :conditions => ['id = ? and parent_id = ?', team.team_id, student.parent_id])
      if current_team != nil
       #@team_user.team_id = current_team.id
       current_team.add_member(User.find(@inv.to_id)) 
      end
    end

    #also update the user's topic id
    participant = Participant.find_by_user_id_and_parent_id(student.user_id,student.parent_id)
    participant.update_topic_id(Participant.find_by_user_id_and_parent_id(@inv.from_id,student.parent_id).topic_id)
    #@team_user.user_id = @inv.to_id
    #@team_user.save
    
    redirect_to :controller => 'student_team', :action => 'view', :id => student.id
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
