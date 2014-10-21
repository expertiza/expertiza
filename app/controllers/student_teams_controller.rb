class StudentTeamsController < ApplicationController

  before_action :set_student, only: [:view, :update, :edit]
  before_action :set_team, only: [:edit, :update]
  before_action Proc.new {return unless current_user_id?(@student.user_id)}, only: [:view, :create, :edit, :leave]

  autocomplete :user, :name

  def action_allowed?
    current_role_name.eql? ("Student")
  end

  def view

    @send_invs = Invitation.where from_id: @student.user.id, assignment_id: @student.assignment.id
    @received_invs = Invitation.where to_id: @student.user.id, assignment_id: @student.assignment.id, reply_status: 'W'
  end

  def create

    check = AssignmentTeam.where name: params[:team][:name], parent_id: @student.parent_id

    #check if the team name is in use
    if check.length.empty?
      @team = AssignmentTeam.new params[:team]
      @team.parent_id = @student.parent_id
      @team.save
      parent = AssignmentNode.find_by_node_object_id(@student.parent_id)
      TeamNode.create parent_id: parent.id, node_object_id: @team.id
      user = User.find @student.user_id
      @team.add_member (user, @team.parent_id)

      undo_link("Team \"#{@team.name}\" has been created successfully. ")


           redirect_to view_student_teams_path id: @student.id
    else
      flash[:notice] = 'Team name is already in use.'
      redirect_to view_student_teams_path id: @student.id

    end
  end

  def edit
  end

#kevin up to here
  def update
    check = AssignmentTeam.where( ["name =? and parent_id =?", params[:team][:name], @team.parent_id])
    if (check.length.zero?)
      if @team.update_attributes(params[:team])
        undo_link("Team \"#{@team.name}\" has been updated successfully. ")

        #redirect_to :controller => 'student_teams', :action => 'view', :id => params[:student_id]
        redirect_to view_student_teams_path (:id => params[:student_id])
      end
    elsif (check.length.one? && (check[0].name <=> @team.name).zero?)
      undo_link("Team \"#{@team.name}\" has been updated successfully. ")

      #redirect_to :controller => 'student_teams', :action => 'view', :id => params[:student_id]
      redirect_to view_student_teams_path :id => params[:student_id]
    else
      flash[:notice] = 'Team name is already in use.'
      # redirect_to :controller => 'student_teams', :action => 'edit', :team_id =>params[:team_id], :student_id => params[:student_id]
      redirect_to edit_student_teams_path :team_id => params[:team_id], :student_id => params[:student_id]

    end
  end

  def advertise_for_partners
    Team.update_all("advertise_for_partner=true",:id=>params[:team_id])
    #respond_to do |format|
    #  format.html #  index.html.erb
    #format.xml  { render :xml => @log_entries }
    #end

    #redirect_to :controller => 'student_teams', :action => 'advertise_for_partners' , :id => params[:team_id]

  end
  def remove
    Team.update_all("advertise_for_partner=false",:id=>params[:team_id])

   #redirect_to :controller => 'student_teams', :action => 'view' , :id => params[:team_id]
    redirect_to view_student_teams_path :id => params[:team_id]

  end

  def remove_participant
    participant = AssignmentParticipant.find(params[:student_id])
    return unless current_user_id?(participant.user_id)
    #remove the topic_id from participants
    #>participant should belong to a team, and a team should have topic
    #>then this call becomes participant.update_assigment_team(nil)
    #>Correctly doing the relationship should handle the rest
    #>TeamsUser appears to be a model that captures a relationship. Should be replaced with a
    #>has_a relationship with assignment_team, and a has_and_belongs_to_many relationship in  assignment_participant
    #>the new code here would be
    #>assignment_team=AssignmentTeam.find(params[:team_id])#same as old_team below
    #>participant = AssignmentParticipant.find(params[:student_id])
    #>assignment_team.assignment_participants.delete(participant)
    participant.update_topic_id(nil)



    #remove the entry from teams_users

    #>Relationship which would remove the following block
    team_user = TeamsUser.find_by team_id: params[:team_id], user_id: team_user.user_id

    if team_user
      team_user.destroy

      undo_link("User \"#{team_user.name}\" has been removed from the team successfully. ")
    end

    #>This whole block should be in the models. The controller shouldn't be handling book-keeping like this

    #if your old team does not have any members, delete the entry for the team
    #>could happen with a callback in assignment_team.assignment_participant.delete(participant)
    unless TeamsUser.where(team_id: params[:team_id]).empty?
      old_team = AssignmentTeam.find params[:team_id]
      if old_team#> how on earth could this be null?
        old_team.destroy_all
        #if assignment has signup sheet then the topic selected by the team has to go back to the pool
        #or to the first team in the waitlist

        #>Again, a correctly performed has_a relationship with a callback should cover this!
        #>CROSSING THE BARRIER OF DEMETER
        #>If (a big if) not controlled by a model, it should ATLEAST be moved with ALL OTHER signup management to
        #>a child class of the ApplicationController
        sign_ups = SignedUpUser.where creator_id: params[:team_id]
        sign_ups.each {|sign_up|
          #get the topic_id
          sign_up_topic_id = sign_up.topic_id
          #destroy the sign_up
          sign_up.destroy

          #get the number of non-waitlisted users signed up for this topic
          non_waitlisted_users = SignedUpUser.where topic_id: sign_up_topic_id, is_waitlisted: false
          #get the number of max-choosers for the topic
          max_choosers = SignUpTopic.find(sign_up_topic_id).max_choosers

          #check if this number is less than the max choosers
          if non_waitlisted_users.length < max_choosers
            first_waitlisted_user = SignedUpUser.find_by topic_id: sign_up_topic_id, is_waitlisted: true#<order?

            #moving the waitlisted user into the confirmed signed up users list
            if first_waitlisted_user
              first_waitlisted_user.is_waitlisted = false
              first_waitlisted_user.save

              waitlisted_team_user = TeamsUser.find_by team_id: first_waitlisted_user.creator_id #<this relationship is weird
              #waitlisted_team_user could be nil since the team the student left could have been the one waitlisted on the topic
              #and teams_users for the team has been deleted in one of the earlier lines of code

              if waitlisted_team_user
                user_id = waitlisted_team_user.user_id#<a relationship could be used have waitlisted_team_user.participant
                if user_id#<again, how could this be null?
                  waitlisted_participant = Participant.find_by_user_id(user_id)
                  waitlisted_participant.update_topic_id(nil)

                end
              end
            end
          end

        }
      end
    end

    #remove all the sent invitations
    #>shouldn't invites belong to the team not AssignmentParticipant?
    #>either way, it should be a has_many relationship
    #>Then it would be either
    #>
    old_invites = Invitation.where( ['from_id = ? and assignment_id = ?', team_user.user_id, team_user.parent_id])

    old_invites.each{|old_invite| old_invite.destroy}


    #reset the participants submission directory to nil
    #per EFG:
    #the participant is responsible for resubmitting their work
    #no restriction is placed on when a participant can leave

    participant.directory_num = nil

    participant.save


    #redirect_to :controller => 'student_teams', :action => 'view' , :id => @student.id
    redirect_to view_student_teams_path :id => @student.id
    end

  def set_team
    @team = AssignmentTeam.find(params[:team_id])
  end
  def set_student
    if ["edit", "leave"].include? params[:action]
      student_id = params[:student_id]
    else
      student_id = params[:id]
    end
      @student = AssignmentParticipant.find student_id
  end

  def review
    @assignment = Assignment.find(params[:assignment_id])
    redirect_to controller: 'questionnaire', :action => 'view_questionnaire', :id => @assignment.questionnaires.find_by_type('AuthorFeedbackQuestionnaire').id

  end
end
