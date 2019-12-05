class InvitationsController < ApplicationController
  before_action :check_user_before_invitation, only: [:create]
  before_action :check_team_before_accept, only: [:accept]
  def action_allowed?
    ['Instructor', 'Teaching Assistant', 'Administrator', 'Super-Administrator', 'Student'].include? current_role_name
  end

  def new
    @invitation = Invitation.new
  end

  def create
    # check if the invited user is already invited (i.e. awaiting reply)
    if Invitation.is_invited?(@student.user_id, @user.id, @student.parent_id)
      create_utility
    else
      ExpertizaLogger.error LoggerMessage.new("", @student.name, "Student was already invited")
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
    old_entry.update_attribute("status", 'A') if old_entry
  end

  def auto_complete_for_user_name
    search = params[:user][:name].to_s
    @users = User.where("LOWER(name) LIKE ?", "%#{search}%") if search.present?
  end

  def accept
    # Accept the invite and check whether the add was successful
    accepted = Invitation.accept_invite(params[:team_id], @inv.from_id, @inv.to_id, @student.parent_id)
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
    Invitation.find(params[:inv_id]).destroy
    ExpertizaLogger.info "Successfully retracted invitation #{params[:inv_id]}"
    redirect_to view_student_teams_path student_id: params[:student_id]
  end

  private

  def create_utility
    @invitation = Invitation.new(to_id: @user.id, from_id: @student.user_id)
    @invitation.assignment_id = @student.parent_id
    @invitation.reply_status = 'W'
    @invitation.save
    ExpertizaLogger.info LoggerMessage.new(controller_name, @student.name, "Successfully invited student #{@user.id}", request)
  end

  def user_params
    params.require(:user).permit(:name,
                                 :crypted_password,
                                 :role_id,
                                 :password_salt,
                                 :fullname,
                                 :email,
                                 :parent_id,
                                 :private_by_default,
                                 :mru_directory_path,
                                 :email_on_review,
                                 :email_on_submission,
                                 :email_on_review_of_review,
                                 :is_new_user,
                                 :master_permission_granted,
                                 :handle,
                                 :digital_certificate,
                                 :persistence_token,
                                 :timezonepref,
                                 :public_key,
                                 :copy_of_emails,
                                 :institution_id)
  end

  # define a handle for a new participant
  def set_handle
    self.handle = if self.user.handle.nil? or self.user.handle == ""
                    self.user.name
                  elsif AssignmentParticipant.exists?(parent_id: self.assignment.id, handle: self.user.handle)
                    self.user.name
                  else
                    self.user.handle
                  end
    self.save!
  end

  def check_user_before_invitation
    # user is the student you are inviting to your team
    @user = User.find_by(name: params[:user][:name].strip)
    # student has information about the participant
    @student = AssignmentParticipant.find(params[:student_id])
    @assignment = Assignment.find(@student.parent_id)

    if @assignment.is_conference
      unless @user
        check = User.find_by(name: params[:user][:name])
        params[:user][:name] = params[:user][:email] unless check.nil?
        @newuser = User.new(user_params)
        @user.institution_id =nil
        @newuser.email = params[:user][:name]
        # record the person who created this new user
        @newuser.parent_id = session[:user].id
        @newuser.role_id = 1
        # set the user's timezone to its parent's
        #@newuser.timezonepref = User.find(@user.parent_id).timezonepref
        if @newuser.save
          #flash[:error] = "User Created Successfully "
          @user = User.find_by(email: @newuser.email)

          password = @user.reset_password
          MailerHelper.send_mail_to_user(@user, "Your Expertiza account has been created.", "user_conference_invitation", password).deliver
        end
        #redirect_to view_student_teams_path student_id: @student.id
        #return
      end
    end

    return unless current_user_id?(@student.user_id)

    # check if the invited user is valid
    unless @user
      flash[:error] = "The user \"#{params[:user][:name].strip}\" does not exist. Please make sure the name entered is correct."
      redirect_to view_student_teams_path student_id: @student.id
      return
    end
    check_participant_before_invitation
  end

  def check_participant_before_invitation
    @assignment = Assignment.find(@student.parent_id)
    @participant = AssignmentParticipant.where('user_id = ? and parent_id = ?', @user.id, @student.parent_id).first
    # check if the user is a participant of the assignment
    unless @participant
      if @assignment.is_conference
        new_part = AssignmentParticipant.create(parent_id: @assignment.id,
                                                user_id: @user.id,
                                                permission_granted: @user.master_permission_granted,
                                                can_submit: 1,
                                                can_review: 1,
                                                can_take_quiz: 1)
        new_part.set_handle
      else
        flash[:error] = "The user \"#{params[:user][:name].strip}\" is not a participant of this assignment."
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
    team_member = TeamsUser.where('team_id = ? and user_id = ?', @team.id, @user.id)
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
    TeamsUser.remove_team(@student.user_id, params[:team_id])
  end
end
