class JoinTeamRequestsController < ApplicationController
  # GET /join_team_requests
  # GET /join_team_requests.xml

  def action_allowed?
    current_role_name.eql?("Student")
  end

  def index
    @join_team_requests = JoinTeamRequest.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @join_team_requests }
    end
  end

  # GET /join_team_requests/1
  # GET /join_team_requests/1.xml
  def show
    @join_team_request = JoinTeamRequest.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @join_team_request }
    end
  end

  # GET /join_team_requests/new
  # GET /join_team_requests/new.xml
  def new
    @join_team_request = JoinTeamRequest.new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @join_team_request }
    end
  end

  # GET /join_team_requests/1/edit
  def edit
    @join_team_request = JoinTeamRequest.find(params[:id])
  end

  # POST /join_team_requests
  # POST /join_team_requests.xml
  #create a new join team request entry for join_team_request table and add it to the table
  def create
    #check if the advertisement is from a team member and if so disallow requesting invitations
    team_member=TeamsUser.where(['team_id =? and user_id =?', params[:team_id],session[:user][:id]])
    if (team_member.size > 0)
      flash[:note] = "You are already a member of team."
    else

      @join_team_request = JoinTeamRequest.new
      @join_team_request.comments = params[:comments]
      @join_team_request.status = 'P'
      @join_team_request.team_id = params[:team_id]

      participant = Participant.where(user_id: session[:user][:id], parent_id: params[:assignment_id]).first
      @join_team_request.participant_id= participant.id
      respond_to do |format|
        if @join_team_request.save
          format.html { redirect_to(@join_team_request, :notice => 'JoinTeamRequest was successfully created.') }
          format.xml  { render :xml => @join_team_request, :status => :created, :location => @join_team_request }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @join_team_request.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # PUT /join_team_requests/1
  # PUT /join_team_requests/1.xml
  #update join team request entry for join_team_request table and add it to the table
  def update
    @join_team_request = JoinTeamRequest.find(params[:id])
    respond_to do |format|
      if @join_team_request.update_attributes(params[:join_team_request])
        format.html { redirect_to(@join_team_request, :notice => 'JoinTeamRequest was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @join_team_request.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /join_team_requests/1
  # DELETE /join_team_requests/1.xml

  def destroy
    @join_team_request = JoinTeamRequest.find(params[:id])
    @join_team_request.destroy

    respond_to do |format|
      format.html { redirect_to(join_team_requests_url) }
      format.xml  { head :ok }
    end
  end
  #decline request to join the team...
  def decline
    @join_team_request = JoinTeamRequest.find(params[:id])
    @join_team_request.status = 'D'
    @join_team_request.save
    redirect_to view_student_teams_path student_id: params[:teams_user_id]
  end
end
