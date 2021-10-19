class JoinTeamRequestsController < ApplicationController
  before_action :check_team_status, only: [:create]
  before_action :find_request, only: %i[show edit update destroy decline]

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

  # decline request to join the team...
  def decline
    @join_team_request.status = 'D'
    @join_team_request.save
    redirect_to view_student_teams_path student_id: params[:teams_user_id]
  end

  private

  def check_team_status
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
end
