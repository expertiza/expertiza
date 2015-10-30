class JoinTeamRequestsController < ApplicationController
  # GET /join_team_requests
  # GET /join_team_requests.xml

  def action_allowed?
    ['Student', 'Instructor', 'Teaching Assistant'].include?(current_role_name) #people with this roles can only access the function provied by the controller 
  end

  private def render_request
      respond_to do |format|
      format.html 
      format.xml  { render :xml => @join_team_request } #displays the join team instance
    end
  end

  def index
    @join_team_request = JoinTeamRequest.all #gets all the request to join team  
    render_request # index.html.erb
  end

  # GET /join_team_requests/1
  # GET /join_team_requests/1.xml
  def show # searches the join team requests for a particular id
    @join_team_request = JoinTeamRequest.find(params[:id]) 
    render_request # show.html.erb
  end

  # GET /join_team_requests/new
  # GET /join_team_requests/new.xml
  def new # create a new join team request entry instance
    @join_team_request = JoinTeamRequest.new
    render_request # new.html.erb
  end

  # GET /join_team_requests/1/edit
  def edit # edit join team request entry with a particular id for join_team_request table
    @join_team_request = JoinTeamRequest.find(params[:id])
  end

  # POST /join_team_requests
  # POST /join_team_requests.xml
  #create a new join team request entry for join_team_request table and add it to the table
  def create
    #check if the advertisement is from a team member and if so disallow requesting invitations
    team_member=TeamsUser.where(['team_id =? and user_id =?', params[:team_id],session[:user][:id]])
    if (team_member.size > 0)
      flash[:note] = "You are already a team member."
    else

      @join_team_request = JoinTeamRequest.new
      @join_team_request.comments = params[:comments]
      @join_team_request.status = 'P' #Request status is 'Pending'
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
      if @join_team_request.update_attribute(:comments, params[:join_team_request][:comments])
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

  def destroy # destroy a join_team_request entry of a particular id
    @join_team_request = JoinTeamRequest.find(params[:id])
    if @join_team_request.destroy
      respond_to do |format|
        format.html { redirect_to(join_team_requests_url) }
        format.xml  { head :ok }
      end
    else
      redirect_to root_path, notice: "JoinTeamRequest could not deleted."
    end
  end
  #decline request to join the team...
  def decline
    @join_team_request = JoinTeamRequest.find(params[:id])
    @join_team_request.status = 'D' #'D' stands for decline

    if @join_team_request.save
      redirect_to view_student_teams_path student_id: params[:teams_user_id], notice: "JoinTeamRequest was successfully declined."
    else
      redirect_to root_path, notice: "Decline request could not be performed."
  end
end
end
