class JoinTeamRequestsController < ApplicationController
  before_action :check_team, only: [:create]
  before_action :find_request, only: [:show, :edit, :update, :destroy, :decline,:accept]
  before_action :check_team_before_accept, only: [:accept]
  def action_allowed?
    current_role_name.eql?("Student")
  end

  def index
    @join_team_requests = JoinTeamRequest.all
    respond_after @join_team_requests
  end

  def show
    respond_after @join_team_request
  end

  def new
    @join_team_request = JoinTeamRequest.new
    respond_after @join_team_request
  end

  def edit; end

  # create a new join team request entry for join_team_request table and add it to the table
  def create
    @join_team_request = JoinTeamRequest.new
    @join_team_request.comments = params[:comments]
    @join_team_request.status = 'P'
    @join_team_request.team_id = params[:team_id]

    participant = Participant.where(user_id: session[:user][:id], parent_id: params[:assignment_id]).first
    @join_team_request.participant_id = participant.id
    respond_to do |format|
      if @join_team_request.save
        format.html { redirect_to(@join_team_request, notice: 'JoinTeamRequest was successfully created.') }
        format.xml  { render xml: @join_team_request, status: :created, location: @join_team_request }
      else
        format.html { render action: "new" }
        format.xml  { render xml: @join_team_request.errors, status: :unprocessable_entity }
      end
    end
  end

  # update join team request entry for join_team_request table and add it to the table
  def update
    respond_to do |format|
      if @join_team_request.update_attribute(:comments, params[:join_team_request][:comments])
        format.html { redirect_to(@join_team_request, notice: 'JoinTeamRequest was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render action: "edit" }
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

  def accept
    # Accept the invite and check whether the add was successful
    unless JoinTeamRequest.accept_invite(params[:team_id], @inviter_userid,  @invited_userid, @assignment_id)
      flash[:error] = 'The system failed to add you to the team that invited you.'
    end

    redirect_to view_student_teams_path student_id: params[:student_id]
  end

  # decline request to join the team...
  def decline
    @join_team_request.status = 'D'
    @join_team_request.save
    redirect_to view_student_teams_path student_id: params[:teams_user_id]
  end

  private

  def check_team
    # check if the advertisement is from a team member and if so disallow requesting invitations
    team_member = TeamsUser.where(['team_id =? and user_id =?', params[:team_id], session[:user][:id]])
    team = Team.find(params[:team_id])

    return flash[:error] = "This team is full." if team.full?

    return flash[:error] = "You are already a member of this team." unless team_member.empty?
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

  def check_team_before_accept
    @inviter_userid=(params[:inviter_user_id]).to_i
    @assignment_id=(params[:invited_assignment_id]).to_i
    # check if the inviter's team is still existing, and have available slot to add the invitee
    inviter_assignment_team = AssignmentTeam.team(AssignmentParticipant.find_by(user_id: @inviter_userid, parent_id:@assignment_id))
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
    @join_team_request.status = 'A'
    @join_team_request.save
    @invited_userid=(params[:invited_user_id]).to_i

    # Remove the users previous team since they are accepting an invite for possibly a new team.
    TeamsUser.remove_team(@invited_userid, params[:team_id])
  end

end
