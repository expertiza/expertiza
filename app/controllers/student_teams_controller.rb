class StudentTeamsController < ApplicationController
  autocomplete :user, :name

  def team
    @team ||= AssignmentTeam.find params[:team_id]
  end
  def team=(value)
    @team = value
  end

  def student
    @student ||= AssignmentParticipant.find(params[:student_id])
  end

  def student=(value)
    @student = value
  end

  before_action :team, only: [:edit, :update]
  before_action :student, only: [:view, :update, :edit, :create, :remove_participant]


  def action_allowed?
    #note, this code replaces the following line that cannot be called before action allowed?
    if current_role_name.eql? 'Student'
      #make sure the student is the owner if they are trying to create it
      return current_user_id? student.user_id if %w[create].include? action_name
      #make sure the student belongs to the group before allowed them to try and edit or update
      return team.get_participants.map{|p| p.user_id}.include? current_user.id if %w(edit update).include? action_name
      return true
    else
      return false
    end
  end

  def view
    #View will check if send_invs and recieved_invs are set before showing
    #only the owner should be able to see those.
    return unless current_user_id? student.user_id

    @send_invs = Invitation.where from_id: student.user.id, assignment_id: student.assignment.id
    @received_invs = Invitation.where to_id: student.user.id, assignment_id: student.assignment.id, reply_status: 'W'
  end

  def create
    existing_assignments = AssignmentTeam.where name: params[:team][:name], parent_id: student.parent_id

    #check if the team name is in use
    if existing_assignments.empty?
      team = AssignmentTeam.new params[:team]
      team.parent_id = student.parent_id
      team.save
      parent = AssignmentNode.find_by_node_object_id student.parent_id
      TeamNode.create parent_id: parent.id, node_object_id: team.id
      user = User.find student.user_id
      team.add_member user, team.parent_id
      team_created_successfully(team)
      redirect_to view_student_teams_path student_id: student.id

    else
      flash[:notice] = 'Team name is already in use.'
      redirect_to view_student_teams_path student_id: student.id
    end
  end

  def edit
  end

  def update
    matching_teams = AssignmentTeam.where name: params[:team][:name], parent_id: team.parent_id
    if matching_teams.length.zero?
      if team.update_attributes params[:team]
        team_created_successfully

          redirect_to view_student_teams_path student_id: params[:student_id]

      end
    elsif matching_teams.length == 1 && (matching_teams[0].name <=> team.name).zero?

      team_created_successfully
      redirect_to view_student_teams_path student_id: params[:student_id]

    else
      flash[:notice] = 'Team name is already in use.'

      redirect_to edit_student_teams_path team_id: params[:team_id], student_id: params[:student_id]

    end
  end

  def advertise_for_partners
    Team.update_all advertise_for_partner: true, id: params[:team_id]
  end

  def remove_advertisement
    Team.update_all advertise_for_partner: false, id: params[:team_id]
    redirect_to view_student_teams_path student_id: params[:team_id]
  end

  def remove_participant
    #remove the topic_id from participants
    student.update_topic_id nil

    #remove the entry from teams_users

    team_user = TeamsUser.find_by team_id: params[:team_id], user_id: student.user_id

    if team_user
      team_user.destroy

      undo_link "User \"#{team_user.name}\" has been removed from the team successfully. "
    end

    #if your old team does not have any members, delete the entry for the team
    if TeamsUser.where(team_id: params[:team_id]).empty?
      old_team = AssignmentTeam.find params[:team_id]
      if old_team
        old_team.destroy
        #if assignment has signup sheet then the topic selected by the team has to go back to the pool
        #or to the first team in the waitlist

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
                user_id = waitlisted_team_user.user_id
                if user_id
                  waitlisted_participant = Participant.find_by_user_id user_id
                  waitlisted_participant.update_topic_id nil

                end
              end
            end
          end

        }
      end
    end

    #remove all the sent invitations
    old_invites = Invitation.where from_id: student.user_id, assignment_id: student.parent_id

    old_invites.each{|old_invite| old_invite.destroy}

    #reset the participants submission directory to nil
    #per EFG:
    #the student is responsible for resubmitting their work
    #no restriction is placed on when a student can leave

    student.directory_num = nil

    student.save

    redirect_to view_student_teams_path student_id: student.id
  end

  def team_created_successfully(current_team=nil)
    if current_team
      undo_link "Team \"#{current_team.name}\" has been updated successfully. "
    else
      undo_link "Team \"#{team.name}\" has been updated successfully. "
    end
  end



  def review
    @assignment = Assignment.find params[:assignment_id]
    redirect_to view_questionnaires_path id: @assignment.questionnaires.find_by_type('AuthorFeedbackQuestionnaire').id
  end
end
