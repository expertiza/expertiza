class StudentTeamController < ApplicationController
  auto_complete_for :user, :name

  def action_allowed?
    current_role_name.eql?("Student")
  end

  def view
    @student = AssignmentParticipant.find(params[:id])
    return unless current_user_id?(@student.user_id)

    @send_invs = Invitation.where( ['from_id = ? and assignment_id = ?', @student.user.id, @student.assignment.id])
    @received_invs = Invitation.where( ['to_id = ? and assignment_id = ? and reply_status = "W"', @student.user.id, @student.assignment.id])
  end

  def create
    @student = AssignmentParticipant.find(params[:id])
    return unless current_user_id?(@student.user_id)

    check = AssignmentTeam.where( ["name =? and parent_id =?", params[:team][:name], @student.parent_id])

    #check if the team name is in use
    if (check.length == 0)
      @team = AssignmentTeam.new(params[:team])
      @team.parent_id = @student.parent_id
      @team.save
      parent = AssignmentNode.find_by_node_object_id(@student.parent_id)
      TeamNode.create(:parent_id => parent.id, :node_object_id => @team.id)
      user = User.find(@student.user_id)
      @team.add_member(user, @team.parent_id)

      undo_link("Team \"#{@team.name}\" has been created successfully. ")

      redirect_to :controller => 'student_team', :action => 'view' , :id=> @student.id
    else
      flash[:notice] = 'Team name is already in use.'
      redirect_to :controller => 'student_team', :action => 'view' , :id=> @student.id
    end
  end

  def edit
    @team = AssignmentTeam.find_by_id(params[:team_id])
    @student = AssignmentParticipant.find(params[:student_id])
    return unless current_user_id?(@student.user_id)
  end

  def update
    @team = AssignmentTeam.find_by_id(params[:team_id])
    check = AssignmentTeam.where( ["name =? and parent_id =?", params[:team][:name], @team.parent_id])
    if (check.length == 0)
      if @team.update_attributes(params[:team])
        undo_link("Team \"#{@team.name}\" has been updated successfully. ")

        redirect_to :controller => 'student_team', :action => 'view', :id => params[:student_id]
      end
    elsif (check.length == 1 && (check[0].name <=> @team.name) == 0)
      undo_link("Team \"#{@team.name}\" has been updated successfully. ")

      redirect_to :controller => 'student_team', :action => 'view', :id => params[:student_id]
    else
      flash[:notice] = 'Team name is already in use.'
      redirect_to :controller =>'student_team', :action => 'edit', :team_id =>params[:team_id], :student_id => params[:student_id]
    end
  end

  def advertise
    Team.update_all("advertise_for_partner=true",:id=>params[:team_id])
    #respond_to do |format|
    #  format.html #  index.html.erb
    #format.xml  { render :xml => @log_entries }
    #end
    #redirect_to :controller => 'student_team', :action => 'advertise_for_partners' , :id => params[:team_id]
  end
  def remove_advertisement
    Team.update_all("advertise_for_partner=false",:id=>params[:team_id])

    redirect_to :controller => 'student_team', :action => 'view' , :id => params[:team_id]
  end

  def leave
    @student = AssignmentParticipant.find(params[:student_id])
    return unless current_user_id?(@student.user_id)
    #remove the topic_id from participants
    @student.update_topic_id(nil)

    #remove the entry from teams_users
    user = TeamsUser.where(["team_id =? and user_id =?", params[:team_id], @student.user_id]).first
#   user = TeamsUser.find(:first, :conditions =>["team_id =? and user_id =?", params[:team_id], @student.user_id])
    if user
      user.destroy

      undo_link("User \"#{user.name}\" has been removed from the team successfully. ")
    end

    #if your old team does not have any members, delete the entry for the team
    other_members = TeamsUser.where( ['team_id = ?', params[:team_id]])
    if other_members.count == 0
      old_team = AssignmentTeam.where( ['id = ?', params[:team_id]])
      if old_team
        old_team.destroy_all
        #if assignment has signup sheet then the topic selected by the team has to go back to the pool
        #or to the first team in the waitlist
        signups = SignedUpUser.where( {:creator_id => params[:team_id]})
        signups.each {|signup|
          #get the topic_id
          signup_topic_id = signup.topic_id
          #destroy the signup
          signup.destroy

          #get the number of non-waitlisted users signed up for this topic
          non_waitlisted_users = SignedUpUser.where( {:topic_id => signup_topic_id, :is_waitlisted => false})
          #get the number of max-choosers for the topic
          max_choosers = SignUpTopic.where( {:id => signup_topic_id}).first.max_choosers

          #check if this number is less than the max choosers
          if non_waitlisted_users.length < max_choosers
            first_waitlisted_user = SignedUpUser.where( {:topic_id => signup_topic_id, :is_waitlisted => true}).first

            #moving the waitlisted user into the confirmed signed up users list
            if !first_waitlisted_user.nil?
              first_waitlisted_user.is_waitlisted = false
              first_waitlisted_user.save

              waitlisted_team_user = TeamsUser.where( {:team_id => first_waitlisted_user.creator_id}).first
              #waitlisted_team_user could be nil since the team the student left could have been the one waitlisted on the topic
              #and teams_users for the team has been deleted in one of the earlier lines of code

              if !waitlisted_team_user.nil?
                user_id = waitlisted_team_user.user_id
                if !user_id.nil?
                  participant = Participant.find_by_user_id(user_id)
                  participant.update_topic_id(nil)
                end
              end
            end
          end
          #signup.destroy
        }
      end
    end

    #remove all the sent invitations
    old_invs = Invitation.where( ['from_id = ? and assignment_id = ?', @student.user_id, @student.parent_id])
    for old_inv in old_invs
      old_inv.destroy
    end

    #reset the participants submission directory to nil
    #per EFG:
    #the participant is responsible for resubmitting their work
    #no restriction is placed on when a participant can leave
    @student.directory_num = nil
    @student.save

    redirect_to :controller => 'student_team', :action => 'view' , :id => @student.id
    end
end
