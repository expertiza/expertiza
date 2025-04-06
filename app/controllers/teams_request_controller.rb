class TeamsRequestController < ApplicationController
   include AuthorizationHelper
   include ConferenceHelper
  
   before_action is_participant_a_valid_user?, :is_user_already_a_member_of_the_team? only: [:create]
   before_action :team_exists_and_has_room?, only: [:accept]
   before_action :find_request, only: %i[show edit update destroy decline]
  
   def action_allowed?
      current_user_has_student_privileges?
   end
   def index
      unless current_user_has_admin_privileges?
          redirect_to '/'
          return
      end
      @join_team_requests = JoinTeamRequest.all
      respond_after @join_team_requests
   end
   def new
      if params[:inv]==1
          @invitation = Invitation.new
      else
          @join_team_request = JoinTeamRequest.new
          respond_after @join_team_request
          @join_team_request.team_id = params[:team_id]
      
          participant = Participant.where(user_id: session[:user][:id], parent_id: params[:assignment_id]).first
          team = Team.find(params[:team_id])
          if team.participants.include? participant
            flash[:error] = 'You already belong to the team'
            redirect_back
            return
          end
          @join_team_request.participant_id = participant.id
          respond_to do |format|
            if @join_team_request.save
              format.html { redirect_to(@join_team_request, notice: 'JoinTeamRequest was successfully created.') }
              format.xml  { render xml: @join_team_request, status: :created, location: @join_team_request }
            else
              format.html { render action: 'new' }
              format.xml  { render xml: @join_team_request.errors, status: :unprocessable_entity }
            end
          end
      end
    end
   
   def edit; end
  
   def auto_complete_for_user_name
      search = params[:user][:name].to_s
      @users = User.where('LOWER(name) LIKE ?', "%#{search}%") if search.present?
   end
  
   def accept
      # Accept the invite and check whether the add was successful
      accepted = Invitation.accept_invitation(params[:team_id], @inv.from_id, @inv.to_id, @student.parent_id)
      flash[:error] = 'The system failed to add you to the team that invited you.' unless accepted
  
      ExpertizaLogger.info "Accepting Invitation #{params[:inv_id]}: #{accepted}"
      redirect_to view_student_teams_path student_id: params[:student_id]
   end
   def decline
   if params[:inv]==1
      @inv = Invitation.find(params[:inv_id])
      # Status code D for declined
      @inv.reply_status = 'D'
      @inv.save
      student = Participant.find(params[:student_id])
      ExpertizaLogger.info "Declined invitation #{params[:inv_id]} sent by #{@inv.from_id}"
      redirect_to view_student_teams_path student_id: student.id
   else
      @join_team_request.status = 'D'
      @join_team_request.save
      redirect_to view_student_teams_path student_id: params[:teams_user_id]
   end
   end
   def cancel
      Invitation.find(params[:inv_id]).destroy
      ExpertizaLogger.info "Successfully retracted invitation #{params[:inv_id]}"
      redirect_to view_student_teams_path student_id: params[:student_id]
   end
   def update
      respond_to do |format|
          if @join_team_request.update(join_team_request_params)
              format.html { redirect_to(@join_team_request, notice: 'JoinTeamRequest was successfully updated.') }
              format.xml  { head :ok }
          else
              format.html { render action: 'edit' }
              format.xml  { render xml: @join_team_request.errors, status: :unprocessable_entity }
          end
      end
   end
   def destroy
      @join_team_request.destroy
  
      respond_to do |format|
          format.html { redirect_to(join_team_requests_url) }
          format.xml  { head :ok }
      end
   end
  
  
   private def create_invitation_utility
      @invitation = Invitation.new(to_id: @user.id, from_id: @student.user_id)
      @invitation.assignment_id = @student.parent_id
      @invitation.reply_status = 'W'
      @invitation.save
      prepared_mail = MailerHelper.send_mail_to_user(@user, 'Invitation Received on Expertiza', 'invite_participant_to_team', '')
      prepared_mail.deliver
      ExpertizaLogger.info LoggerMessage.new(controller_name, @student.name, "Successfully invited student #{@user.id}", request)
    end
    
  
    def does_invited_participant_exist?
      # user is the student you are inviting to your team
      @user = User.find_by(name: params[:user][:name].strip)
      # User/Author has information about the participant
      @student = AssignmentParticipant.find(params[:student_id])
      @assignment = Assignment.find(@student.parent_id)
  
      # try to remove conference assignment logic from this method
      # Try to move it to a error handler
      @user ||= create_coauthor if is_assignment_conference_assignment?(@assignment)
  
      return unless current_user_id?(@student.user_id)
  
      # check if the invited user is valid
      unless @user
        flash[:error] = "The user \"#{params[:user][:name].strip}\" does not exist. Please make sure the name entered is correct."
        redirect_to view_student_teams_path student_id: @student.id
        return
      end
      check_for_assignment_participation_before_invitation
    end
    def is_assignment_conference_assignment?(assignment)
      return assignment.is_conference_assignment
    end
    # invite only if the student is a participant in the assignment 
    # invitee_is_participating_in_assignment
   def check_for_assignment_participation_before_invitation
      @participant = AssignmentParticipant.where('user_id = ? and parent_id = ?', @user.id, @student.parent_id).first
      # check if the user is a participant in the assignment
      # To do: Invitations should not have to know about conference assignments; it makes it harder to understand this code.
      unless @participant
        if is_assignment_conference_assignment(@assignment)
          add_participant_coauthor
        else
          flash[:error] = "The user \"#{params[:user][:name].strip}\" is not a participant in this assignment."
          redirect_to view_student_teams_path student_id: @student.id
          return
        end
      end
      is_user_already_a_member_of_the_team?
      # room_for_another_member?
    end
  
  
  
   def is_user_already_a_member_of_the_team?
       # participant information about student you are trying to invite to the team
       team_member = TeamsUser.where('team_id = ? and user_id = ?', @team.id, @user.id)
       # check if invited user is already in the team
   
       return if team_member.empty?
   
       flash[:error] = "The user \"#{@user.name}\" is already a member of the team."
       redirect_to view_student_teams_path student_id: @student.id
   end
  
   def team_exists_and_has_room?
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
        accept_invitation
      end
   end
  
   def accept_invitation
      # Status code A for accepted
      @inv.reply_status = 'A'
      @inv.save
  
      @student = Participant.find(params[:student_id])
      # Remove the users previous team since they are accepting an invite for possibly a new team.
      TeamsUser.remove_team(@student.user_id, params[:team_id])
   end
  
  
   def find_request
      @join_team_request = JoinTeamRequest.find(params[:id])
   end
  
   def respond_after(request)
      respond_to do |format|
        format.html
        format.xml { render xml: request }
      end
   end
  
   def join_team_request_params
      params.require(:join_team_request).permit(:comments, :status)
   end
   end
  
  
   end